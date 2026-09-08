import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/ai/parsed_intent.dart';

class QuickAddPreviewCard extends StatelessWidget {
  const QuickAddPreviewCard({
    super.key,
    required this.intent,
    required this.onConfirm,
    required this.onCancel,
    this.onEdit,
    this.isSaving = false,
  });

  final ParsedIntent intent;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback? onEdit;
  final bool isSaving;

  String _moduleLabel() {
    switch (intent.module) {
      case QuickAddModule.money:
        return 'টাকা-পয়সা (Money)';
      case QuickAddModule.bill:
        return 'ইউটিলিটি বিল (Bills)';
      case QuickAddModule.medicine:
        return 'ওষুধ (Medicines)';
      case QuickAddModule.sim:
        return 'সিম ও রিচার্জ (Recharge)';
      case QuickAddModule.task:
        return 'টাস্ক ও কাজ (Tasks)';
      case QuickAddModule.document:
        return 'জরুরি নথি (Documents)';
      case QuickAddModule.unknown:
        return 'অজানা (Unknown)';
    }
  }

  IconData _moduleIcon() {
    switch (intent.module) {
      case QuickAddModule.money:
        return Icons.payments_outlined;
      case QuickAddModule.bill:
        return Icons.receipt_long_outlined;
      case QuickAddModule.medicine:
        return Icons.medication_outlined;
      case QuickAddModule.sim:
        return Icons.sim_card_outlined;
      case QuickAddModule.task:
        return Icons.check_circle_outline;
      case QuickAddModule.document:
        return Icons.folder_outlined;
      case QuickAddModule.unknown:
        return Icons.help_outline;
    }
  }

  Color _moduleColor() {
    switch (intent.module) {
      case QuickAddModule.money:
        return AppColors.brandGreen;
      case QuickAddModule.bill:
        return AppColors.important;
      case QuickAddModule.medicine:
        return AppColors.critical;
      case QuickAddModule.sim:
        return AppColors.accent;
      case QuickAddModule.task:
        return AppColors.brandGreenDark;
      case QuickAddModule.document:
        return AppColors.normal;
      case QuickAddModule.unknown:
        return AppColors.inkMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _moduleColor();
    final confidence = (intent.confidence * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_moduleIcon(), color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_moduleLabel(),
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: color, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(intent.summary(),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.inkMuted.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text('$confidence% মিল',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.inkMuted)),
              ),
            ],
          ),
          if (intent.originalText.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'ইনপুট: "${intent.originalText}"',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.inkMuted, fontStyle: FontStyle.italic),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              OutlinedButton(
                onPressed: isSaving ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                ),
                child: const Text('বাতিল'),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: isSaving ? null : onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                  ),
                  child: const Text('এডিট'),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 2),
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(
                    isSaving ? 'সংরক্ষণ হচ্ছে...' : 'সংরক্ষণ করুন',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}