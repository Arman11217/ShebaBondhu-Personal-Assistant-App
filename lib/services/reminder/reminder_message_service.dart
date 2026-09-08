import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/money_entry.dart';

/// Professional service to format and dispatch polite Bangla payment reminders
/// via WhatsApp, SMS, or System Share Sheet.
class ReminderMessageService {
  /// Generates a polite, respectful Bengali payment reminder.
  static String generatePoliteMessage({
    required String personName,
    required double amount,
    DateTime? dueDate,
  }) {
    final amountStr = amount.toStringAsFixed(0);
    final dateStr = dueDate != null
        ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
        : 'সুবিধাজনক সময়ে';

    return 'আসসালামু আলাইকুম $personName ভাই,\n\n'
        'আশা করি ভালো আছেন। ‘সেবা বন্ধু’ অ্যাপের হিসাব অনুযায়ী আপনার কাছে ৳$amountStr পাওনা রয়েছে। '
        '(পরিশোধের সম্ভাব্য তারিখ: $dateStr)।\n\n'
        'আপনার সুবিধাজনক সময়ে টাকাটি পরিশোধ করলে বিশেষ উপকৃত হব। ধন্যবাদ!';
  }

  /// Generates an official / business invoice style reminder.
  static String generateBusinessMessage({
    required String personName,
    required double amount,
    DateTime? dueDate,
  }) {
    final amountStr = amount.toStringAsFixed(0);
    final dateStr = dueDate != null
        ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
        : 'জরুরি ভিত্তিতে';

    return 'সম্মানিত $personName,\n'
        'বকেয়া তাগাদা: ৳$amountStr\n'
        'পরিশোধের তারিখ: $dateStr\n\n'
        'অনুরোধপূর্বক বকেয়া বিল/টাকা পরিশোধ করার জন্য বিনীত অনুরোধ করা হচ্ছে।\n'
        '— সেবা বন্ধু ডিজিটাল রিমাইন্ডার';
  }

  /// Show the bottom sheet dialog allowing the user to pick tone and send via WhatsApp / SMS / Share.
  static void showReminderBottomSheet({
    required BuildContext context,
    required MoneyEntry entry,
  }) {
    final politeMsg = generatePoliteMessage(
      personName: entry.person,
      amount: entry.amount,
      dueDate: entry.dueDate,
    );
    final businessMsg = generateBusinessMessage(
      personName: entry.person,
      amount: entry.amount,
      dueDate: entry.dueDate,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReminderSheetWidget(
        entry: entry,
        politeMsg: politeMsg,
        businessMsg: businessMsg,
      ),
    );
  }

  /// Clean and format phone number for WhatsApp and SMS.
  /// Converts Bengali digits to ASCII and prefixes country code for Bangladesh.
  static String? formatPhoneNumber(String? raw) {
    if (raw == null) return null;
    const bnToEn = {
      '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
      '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9',
    };
    var s = raw;
    bnToEn.forEach((k, v) => s = s.replaceAll(k, v));
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('01') && digits.length == 11) {
      return '88$digits';
    }
    if (digits.startsWith('8801') && digits.length == 13) {
      return digits;
    }
    return digits;
  }

  /// Send via WhatsApp with optional direct recipient phone number
  static Future<void> sendWhatsApp(String text, {String? phoneNumber}) async {
    final encoded = Uri.encodeComponent(text);
    final targetPhone = formatPhoneNumber(phoneNumber);

    Uri appUri;
    Uri webUri;
    if (targetPhone != null && targetPhone.isNotEmpty) {
      appUri = Uri.parse('whatsapp://send?phone=$targetPhone&text=$encoded');
      webUri = Uri.parse('https://wa.me/$targetPhone?text=$encoded');
    } else {
      appUri = Uri.parse('whatsapp://send?text=$encoded');
      webUri = Uri.parse('https://wa.me/?text=$encoded');
    }

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        // ignore: deprecated_member_use
        await Share.share(text);
      }
    } catch (_) {
      // ignore: deprecated_member_use
      await Share.share(text);
    }
  }

  /// Send via native SMS app with optional direct recipient phone number
  static Future<void> sendSms(String text, {String? phoneNumber}) async {
    final encoded = Uri.encodeComponent(text);
    final targetPhone = formatPhoneNumber(phoneNumber) ?? '';
    // Normalize to domestic 01... for local SMS intent if desired, or use targetPhone
    final smsNumber = targetPhone.startsWith('8801')
        ? targetPhone.substring(2)
        : targetPhone;

    final uri = smsNumber.isNotEmpty
        ? Uri.parse('sms:$smsNumber?body=$encoded')
        : Uri.parse('sms:?body=$encoded');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // ignore: deprecated_member_use
        await Share.share(text);
      }
    } catch (_) {
      // ignore: deprecated_member_use
      await Share.share(text);
    }
  }

  /// Direct phone dialer
  static Future<void> callPhone(String phoneNumber) async {
    final formatted = formatPhoneNumber(phoneNumber);
    if (formatted == null || formatted.isEmpty) return;
    final telUri = Uri.parse('tel:+$formatted');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      }
    } catch (_) {}
  }
}

class _ReminderSheetWidget extends StatefulWidget {
  const _ReminderSheetWidget({
    required this.entry,
    required this.politeMsg,
    required this.businessMsg,
  });

  final MoneyEntry entry;
  final String politeMsg;
  final String businessMsg;

  @override
  State<_ReminderSheetWidget> createState() => _ReminderSheetWidgetState();
}

class _ReminderSheetWidgetState extends State<_ReminderSheetWidget> {
  int _selectedTone = 0; // 0 = Polite, 1 = Business
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController =
        TextEditingController(text: widget.entry.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _currentText =>
      _selectedTone == 0 ? widget.politeMsg : widget.businessMsg;

  @override
  Widget build(BuildContext context) {
    final hasPhone = _phoneController.text.trim().isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxxl,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF25D366),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'তাগাদা বার্তা পাঠান (${widget.entry.person})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                        ),
                        Text(
                          'বকেয়া: ৳${widget.entry.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Phone number input field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.brandGreen, size: 20),
                  suffixIcon: hasPhone
                      ? IconButton(
                          tooltip: 'সরাসরি কল করুন',
                          icon: const Icon(Icons.phone_in_talk_rounded,
                              color: AppColors.brandGreen, size: 20),
                          onPressed: () => ReminderMessageService.callPhone(
                              _phoneController.text.trim()),
                        )
                      : null,
                  labelText: 'প্রাপকের ফোন নম্বর (ঐচ্ছিক)',
                  hintText: '০১৭১২-৩৪৫৬৭৮ (হোয়াটসঅ্যাপ বা এসএমএস পাঠাতে)',
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                ),
              ),
              if (hasPhone) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.brandGreen),
                    const SizedBox(width: 4),
                    Text(
                      'এই নম্বরে সরাসরি মেসেজ চলে যাবে',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.brandGreenDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Tone selector tabs
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('বিনম্র বার্তা (Friend/Customer)'),
                      selected: _selectedTone == 0,
                      onSelected: (val) {
                        if (val) setState(() => _selectedTone = 0);
                      },
                      selectedColor: AppColors.brandGreenLight,
                      labelStyle: TextStyle(
                        color: _selectedTone == 0
                            ? AppColors.brandGreenDark
                            : AppColors.inkMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('অফিসিয়াল নোটিশ'),
                      selected: _selectedTone == 1,
                      onSelected: (val) {
                        if (val) setState(() => _selectedTone = 1);
                      },
                      selectedColor: AppColors.brandGreenLight,
                      labelStyle: TextStyle(
                        color: _selectedTone == 1
                            ? AppColors.brandGreenDark
                            : AppColors.inkMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Message preview box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(
                  _currentText,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ReminderMessageService.sendWhatsApp(
                          _currentText,
                          phoneNumber: _phoneController.text.trim(),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18),
                      label: const Text(
                        'হোয়াটসঅ্যাপ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ReminderMessageService.sendSms(
                          _currentText,
                          phoneNumber: _phoneController.text.trim(),
                        );
                      },
                      icon: const Icon(Icons.sms_outlined, size: 18),
                      label: const Text(
                        'এসএমএস',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'অন্যান্য অ্যাপে শেয়ার',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.outline),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // ignore: deprecated_member_use
                      Share.share(
                        _currentText,
                        subject: 'বকেয়া তাগাদা — সেবা বন্ধু',
                      );
                    },
                    icon:
                        const Icon(Icons.share_rounded, color: AppColors.ink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
