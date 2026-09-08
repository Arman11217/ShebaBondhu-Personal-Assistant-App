import 'package:flutter/material.dart';

import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_colors.dart';

/// Renders a "Due today" / "Due tomorrow" / "in 4 days" label.
class DueLabel extends StatelessWidget {
  const DueLabel({super.key, required this.when});

  final DateTime when;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateTime.now();
    final diff = DateTime(when.year, when.month, when.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    String text;
    Color color;
    if (diff <= 0) {
      text = l10n.dueToday;
      color = AppColors.critical;
    } else if (diff == 1) {
      text = l10n.dueTomorrow;
      color = AppColors.important;
    } else {
      text = l10n.daysRemaining(diff);
      color = AppColors.inkMuted;
    }

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    );
  }
}
