import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class QuickAddInput extends StatefulWidget {
  const QuickAddInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmit,
    required this.onMic,
    required this.isListening,
    this.micSupported = true,
    this.onPickImage,
    this.attachedImageName,
    this.onClearImage,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;
  final VoidCallback onMic;
  final bool isListening;
  final bool micSupported;
  final VoidCallback? onPickImage;
  final String? attachedImageName;
  final VoidCallback? onClearImage;

  @override
  State<QuickAddInput> createState() => _QuickAddInputState();
}

class _QuickAddInputState extends State<QuickAddInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        widget.attachedImageName != null && widget.attachedImageName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.brandGreenLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.brandGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_outlined,
                    size: 18, color: AppColors.brandGreen),
                const SizedBox(width: AppSpacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    widget.attachedImageName!,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.brandGreenDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onClearImage != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: widget.onClearImage,
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isListening
                  ? AppColors.brandGreen
                  : AppColors.outline.withValues(alpha: 0.7),
              width: widget.isListening ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isListening
                    ? AppColors.brandGreen.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: widget.isListening ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.onPickImage != null)
                IconButton(
                  tooltip: 'ছবি বা বিল সংযুক্ত করুন',
                  onPressed: widget.onPickImage,
                  icon: const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.brandGreen,
                    size: 22,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onSubmit(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.isListening
                        ? 'শুনছি... কথা বলুন'
                        : widget.hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.isListening
                          ? AppColors.brandGreen
                          : AppColors.inkMuted,
                      fontWeight: widget.isListening
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Prominent, beautiful Mic Button
              ScaleTransition(
                scale: widget.isListening
                    ? _pulseAnimation
                    : const AlwaysStoppedAnimation(1.0),
                child: Material(
                  color: widget.isListening
                      ? AppColors.critical
                      : AppColors.brandGreenLight,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: widget.onMic,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        widget.isListening
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                        color: widget.isListening
                            ? AppColors.white
                            : AppColors.brandGreenDark,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Send Button
              Material(
                color: AppColors.brandGreen,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: widget.onSubmit,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
