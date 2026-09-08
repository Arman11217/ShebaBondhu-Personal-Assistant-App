import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/severity.dart';

/// Round colored avatar that represents a category.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.icon,
    this.severity = Severity.normal,
    this.size = 44,
  });

  final IconData icon;
  final Severity severity;
  final double size;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (severity == Severity.critical) {
      bg = AppColors.criticalSoft;
      fg = AppColors.critical;
    } else if (severity == Severity.important) {
      bg = AppColors.importantSoft;
      fg = AppColors.important;
    } else {
      bg = AppColors.brandGreenLight;
      fg = AppColors.brandGreen;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: fg, size: size * 0.5),
    );
  }
}
