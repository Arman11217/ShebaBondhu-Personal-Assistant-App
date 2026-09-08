import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/ai/parsed_intent.dart';
import '../../services/ai/gemini_service.dart';
import '../../services/ai/quick_add_dispatcher.dart';
import 'quick_add_input.dart';
import 'quick_add_preview_card.dart';
import 'quick_add_routes.dart';

/// Production-ready Quick-Add Sheet that captures natural-language, voice,
/// or image/bill input, parses it via [GeminiService], and saves to database.
class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({
    super.key,
    required this.geminiService,
    this.dispatcher,
  });

  final GeminiService geminiService;
  final QuickAddDispatcher? dispatcher;

  static Future<void> show({
    required BuildContext context,
    required GeminiService geminiService,
    QuickAddDispatcher? dispatcher,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(
        geminiService: geminiService,
        dispatcher: dispatcher,
      ),
    );
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isListening = false;
  bool _micSupported = false;
  late final stt.SpeechToText _speech = stt.SpeechToText();
  bool _parsing = false;
  bool _isSaving = false;
  ParsedIntent? _intent;
  String? _error;

  Uint8List? _imageBytes;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _micSupported = await _speech.initialize(
        onError: (e) {
          debugPrint('STT error: $e');
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (s) {
          debugPrint('STT status: $s');
          if (s == 'done' || s == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (e) {
      debugPrint('STT init exception: $e');
      _micSupported = false;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.brandGreen),
                ),
                title: const Text('ক্যামেরা দিয়ে ছবি তুলুন',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('বিদ্যুৎ বিল, প্রেসক্রিপশন বা রসিদের ছবি'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _imageBytes = bytes;
                      _imageName = file.name;
                    });
                    _submit();
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.brandGreen),
                ),
                title: const Text('গ্যালারি থেকে নির্বাচন করুন',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('সংরক্ষিত ছবি বা রসিদের ফাইল'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _imageBytes = bytes;
                      _imageName = file.name;
                    });
                    _submit();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      if (_controller.text.trim().isNotEmpty) {
        _submit();
      }
      return;
    }

    // 1. Check & request microphone permission
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    if (!micStatus.isGranted) {
      if (!mounted) return;
      _showMicrophonePermissionDialog();
      return;
    }

    // 2. Initialize SpeechToText if not yet initialized
    if (!_micSupported) {
      try {
        _micSupported = await _speech.initialize(
          onError: (e) {
            debugPrint('STT on-demand error: $e');
            if (mounted) setState(() => _isListening = false);
          },
          onStatus: (s) {
            if (s == 'done' || s == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
        );
      } catch (_) {
        _micSupported = false;
      }
    }

    if (!_micSupported) {
      if (!mounted) return;
      _showMicrophonePermissionDialog();
      return;
    }

    setState(() {
      _isListening = true;
      _error = null;
    });

    // Pick best Bengali locale supported on device
    String? localeId;
    try {
      final locales = await _speech.locales();
      // 1. Prefer bn_BD (Bangla - Bangladesh)
      final bdLocale = locales.where((l) => l.localeId == 'bn_BD' || l.localeId == 'bn-BD');
      if (bdLocale.isNotEmpty) {
        localeId = bdLocale.first.localeId;
      } else {
        // 2. Any Bengali locale (bn_IN etc.)
        final bnLocale = locales.where((l) => l.localeId.startsWith('bn'));
        if (bnLocale.isNotEmpty) {
          localeId = bnLocale.first.localeId;
        } else {
          // 3. Fallback to system locale or first available
          final system = await _speech.systemLocale();
          localeId = system?.localeId;
        }
      }
    } catch (e) {
      debugPrint('Locale detection error: $e');
    }

    try {
      await _speech.listen(
        onResult: (r) {
          if (mounted) {
            setState(() {
              _controller.text = r.recognizedWords;
              _controller.selection = TextSelection.collapsed(
                offset: _controller.text.length,
              );
            });
            if (r.finalResult) {
              setState(() => _isListening = false);
              if (_controller.text.trim().isNotEmpty) {
                _submit();
              }
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          localeId: localeId,
          autoPunctuation: true,
          listenFor: const Duration(seconds: 40),
          pauseFor: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('STT listen error: $e');
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _showMicrophonePermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.mic_off_rounded, color: AppColors.critical, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'মাইক্রোফোন অনুমতি দিন',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: const Text(
          'মুখে বলে দ্রুত কাজ, বিল বা লেনদেন যুক্ত করতে মাইক্রোফোন ব্যবহারের অনুমতি প্রয়োজন।\n\n'
          'নিচের বাটনে চাপ দিয়ে অ্যাপ সেটিংসে গিয়ে মাইক্রোফোন পারমিশন অন করে দিন। একবার অনুমতি দিলে আর এই বার্তাটি আসবে না।',
          style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.ink),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('পরে করব', style: TextStyle(color: AppColors.inkMuted)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: const Text('সেটিংসে যান'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _imageBytes == null) return;
    setState(() {
      _parsing = true;
      _error = null;
      _intent = null;
    });
    final result = await widget.geminiService.parseMultimodal(
      text: text,
      imageBytes: _imageBytes,
    );
    if (!mounted) return;
    setState(() {
      _parsing = false;
      if (result.isOk) {
        _intent = result.intent;
      } else {
        _error = result.error ?? 'তথ্যটি বুঝতে পারিনি। পুনরায় চেষ্টা করুন।';
      }
    });
  }

  Future<void> _confirm() async {
    final intent = _intent;
    if (intent == null || !intent.isActionable) return;

    if (widget.dispatcher != null) {
      setState(() => _isSaving = true);
      final res = await widget.dispatcher!.autoSave(intent);
      if (!mounted) return;
      setState(() => _isSaving = false);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor:
              res.isSuccess ? AppColors.brandGreen : AppColors.critical,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (res.isSuccess) {
        context.push(res.route);
      }
    } else {
      Navigator.of(context).pop();
      QuickAddRoutes.dispatch(context: context, intent: intent);
    }
  }

  void _editManually() {
    final intent = _intent;
    if (intent == null) return;
    Navigator.of(context).pop();
    QuickAddRoutes.dispatch(context: context, intent: intent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = MediaQuery.of(context).viewInsets;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brandGreen, AppColors.brandGreenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: AppColors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI কুইক-অ্যাড (স্মার্ট সহকারী)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'ভয়েস, টেক্সট বা ছবি দিয়ে নিমিষেই যোগ করুন',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Mode Selector Pills (Voice / Scan / Type)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildModeChip(
                      icon: Icons.mic_rounded,
                      label: 'মুখে বলুন',
                      color: AppColors.brandGreen,
                      bgColor: _isListening
                          ? AppColors.brandGreen
                          : AppColors.brandGreenLight,
                      textColor: _isListening
                          ? Colors.white
                          : AppColors.brandGreenDark,
                      onTap: _toggleMic,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildModeChip(
                      icon: Icons.document_scanner_outlined,
                      label: 'বিল স্ক্যান / ছবি',
                      color: AppColors.accent,
                      bgColor: AppColors.accent.withValues(alpha: 0.1),
                      textColor: AppColors.accent,
                      onTap: _pickImage,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildModeChip(
                      icon: Icons.keyboard_alt_outlined,
                      label: 'টাইপ করুন',
                      color: AppColors.inkMuted,
                      bgColor: AppColors.surface,
                      textColor: AppColors.ink,
                      onTap: () {
                        _focusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Active Voice Listening Card
              if (_isListening)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreenLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brandGreen),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGreen.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.brandGreen,
                            child: Icon(Icons.mic, size: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'আমি শুনছি... পরিষ্কারভাবে বলুন',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandGreenDark,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _toggleMic,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.critical.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stop_circle_rounded,
                                      size: 16, color: AppColors.critical),
                                  SizedBox(width: 4),
                                  Text(
                                    'থামান',
                                    style: TextStyle(
                                      color: AppColors.critical,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _controller.text.isNotEmpty
                              ? _controller.text
                              : 'যেমন: "আগামী ৫ তারিখে বিদ্যুৎ বিল দিতে হবে ১০০০ টাকা"',
                          style: TextStyle(
                            fontSize: 13,
                            color: _controller.text.isNotEmpty
                                ? AppColors.ink
                                : AppColors.inkMuted,
                            fontStyle: _controller.text.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Main Input Box
              QuickAddInput(
                controller: _controller,
                hint: 'মুখে বলুন বা বাংলায় লিখুন...',
                onSubmit: _submit,
                onMic: _toggleMic,
                isListening: _isListening,
                micSupported: true,
                onPickImage: _pickImage,
                attachedImageName: _imageName,
                onClearImage: () {
                  setState(() {
                    _imageBytes = null;
                    _imageName = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // AI Parsing State
              if (_parsing)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.brandGreen,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Text(
                          'AI তথ্যটি বিশ্লেষণ করে সাজিয়ে নিচ্ছে...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_intent != null)
                QuickAddPreviewCard(
                  intent: _intent!,
                  isSaving: _isSaving,
                  onConfirm: _confirm,
                  onEdit: _editManually,
                  onCancel: () => Navigator.of(context).pop(),
                )
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.critical.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.critical),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: AppColors.critical)),
                      ),
                    ],
                  ),
                )
              else ...[
                // Category Shortcut Pills & Examples
                _CategoryShortcutGrid(
                  onSelectPrompt: (prompt) {
                    _controller.text = prompt;
                    _submit();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryShortcutGrid extends StatelessWidget {
  const _CategoryShortcutGrid({required this.onSelectPrompt});
  final void Function(String) onSelectPrompt;

  static const _items = <_CategoryPromptItem>[
    _CategoryPromptItem(
      title: 'বিদ্যুৎ বা গ্যাস বিল',
      icon: Icons.flash_on_rounded,
      color: Color(0xFFD97706),
      prompt: 'আগামী ৫ তারিখে বিদ্যুৎ বিল দিতে হবে ১০০০ টাকা',
    ),
    _CategoryPromptItem(
      title: 'পাওনা বা দেনা হিসাব',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.brandGreen,
      prompt: 'হাদি থেকে আগামী মাসের ১০ তারিখে ৫০০ টাকা পাব',
    ),
    _CategoryPromptItem(
      title: 'ওষুধ খাওয়ার রিমাইন্ডার',
      icon: Icons.medication_rounded,
      color: Color(0xFF2563EB),
      prompt: 'আজ রাতে খাওয়ার পর নাপা ৫০০ মিলিগ্রাম খেতে হবে',
    ),
    _CategoryPromptItem(
      title: 'মোবাইল রিচার্জ',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF9333EA),
      prompt: 'বাবার গ্রামীণফোনে ২০০ টাকা রিচার্জ করতে হবে',
    ),
    _CategoryPromptItem(
      title: 'গুরুত্বপূর্ণ কাজ / টাস্ক',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF059669),
      prompt: 'কাল সকালে বাজার থেকে প্রয়োজনীয় বাজার করতে হবে',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded,
                size: 18, color: AppColors.brandGreen),
            const SizedBox(width: 6),
            Text(
              'সহজে যোগ করতে ট্যাপ করুন:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onSelectPrompt(item.prompt),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md - 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 18, color: item.color),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.prompt,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.inkMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: AppColors.inkMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPromptItem {
  final String title;
  final IconData icon;
  final Color color;
  final String prompt;

  const _CategoryPromptItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.prompt,
  });
}