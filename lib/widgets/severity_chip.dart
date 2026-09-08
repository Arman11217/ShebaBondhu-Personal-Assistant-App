import 'package:flutter/material.dart';

import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/severity.dart';

/// Small colored pill that indicates how urgent an item is.
class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});

  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color bg;
    Color fg;
    String label;
    if (severity == Severity.critical) {
      bg = AppColors.criticalSoft;
      fg = AppColors.critical;
      label = l10n.severityCritical;
    } else if (severity == Severity.important) {
      bg = AppColors.importantSoft;
      fg = AppColors.important;
      label = l10n.severityImportant;
    } else {
      bg = AppColors.normalSoft;
      fg = AppColors.normal;
      label = l10n.severityNormal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
