import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Bangla-friendly date picker tile. Shows the selected date in a soft
/// surface card; tapping it opens the Material date picker. Empty state
/// shows the localized hint text.
class DateFieldBn extends StatelessWidget {
  const DateFieldBn({
    super.key,
    required this.value,
    required this.onChanged,
    this.onCleared,
    this.label,
    this.firstDate,
    this.lastDate,
    this.allowClear = false,
  });

  final DateTime? value;

  /// Called with the picked date.
  final ValueChanged<DateTime> onChanged;

  /// Optional callback fired when the user clears the field via the
  /// close button. Only meaningful when [allowClear] is true and a
  /// [value] is currently set. Allows callers with non-nullable state
  /// to reset their local copy without changing [onChanged]'s type.
  final VoidCallback? onCleared;

  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Show a small clear button once a value is picked.
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasValue = value != null;
    final today = DateTime.now();
    final localeTag = Localizations.localeOf(context).languageCode == 'bn'
        ? 'bn_BD'
        : 'en_US';

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? today,
          firstDate: firstDate ?? DateTime(today.year - 2),
          lastDate: lastDate ?? DateTime(today.year + 5),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.brandGreen,
                onPrimary: AppColors.white,
                surface: AppColors.white,
                onSurface: AppColors.ink,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.inkMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  Text(
                    hasValue
                        ? DateFormat.yMMMMEEEEd(localeTag).format(value!)
                        : l10n.dueLabelPickDate,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: hasValue
                              ? AppColors.ink
                              : AppColors.inkMuted,
                        ),
                  ),
                ],
              ),
            ),
            (allowClear && hasValue)
              ? IconButton(
                  tooltip: l10n.dueLabelClearDate,
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.inkMuted,
                  onPressed: onCleared,
                )
              : const Icon(Icons.chevron_right,
                  color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
