import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The 8 modules Quick-Add can route to. Order is significant and is used
/// for default selection and module-tile ordering.
enum QuickAddIntent {
  money,
  bill,
  document,
  warranty,
  medicine,
  sim,
  family,
  task,
}

extension QuickAddIntentX on QuickAddIntent {
  String get key => name;

  /// Friendly label used in the preview card.
  String get displayNameKey {
    switch (this) {
      case QuickAddIntent.money:
        return 'quickAddIntentMoney';
      case QuickAddIntent.bill:
        return 'quickAddIntentBill';
      case QuickAddIntent.document:
        return 'quickAddIntentDocument';
      case QuickAddIntent.warranty:
        return 'quickAddIntentWarranty';
      case QuickAddIntent.medicine:
        return 'quickAddIntentMedicine';
      case QuickAddIntent.sim:
        return 'quickAddIntentSim';
      case QuickAddIntent.family:
        return 'quickAddIntentFamily';
      case QuickAddIntent.task:
        return 'quickAddIntentTask';
    }
  }

  IconData get icon {
    switch (this) {
      case QuickAddIntent.money:
        return Icons.account_balance_wallet_outlined;
      case QuickAddIntent.bill:
        return Icons.receipt_long_outlined;
      case QuickAddIntent.document:
        return Icons.description_outlined;
      case QuickAddIntent.warranty:
        return Icons.verified_outlined;
      case QuickAddIntent.medicine:
        return Icons.medication_outlined;
      case QuickAddIntent.sim:
        return Icons.sim_card_outlined;
      case QuickAddIntent.family:
        return Icons.family_restroom_outlined;
      case QuickAddIntent.task:
        return Icons.check_circle_outline;
    }
  }

  Color get color {
    switch (this) {
      case QuickAddIntent.money:
        return AppColors.brandGreen;
      case QuickAddIntent.bill:
        return AppColors.accent;
      case QuickAddIntent.document:
        return AppColors.brandGreenDark;
      case QuickAddIntent.warranty:
        return AppColors.brandGreen;
      case QuickAddIntent.medicine:
        return AppColors.critical;
      case QuickAddIntent.sim:
        return AppColors.accent;
      case QuickAddIntent.family:
        return AppColors.brandGreenDark;
      case QuickAddIntent.task:
        return AppColors.brandGreen;
    }
  }

  /// Route fragment appended to the module list path, e.g. `/money/edit`.
  /// Returns the path with no leading slash.
  String get editRoutePath {
    switch (this) {
      case QuickAddIntent.money:
        return 'money/edit';
      case QuickAddIntent.bill:
        return 'bills/edit';
      case QuickAddIntent.document:
        return 'documents/edit';
      case QuickAddIntent.warranty:
        return 'warranties/edit';
      case QuickAddIntent.medicine:
        return 'medicines/edit';
      case QuickAddIntent.sim:
        return 'sims/edit';
      case QuickAddIntent.family:
        return 'family/edit';
      case QuickAddIntent.task:
        return 'tasks/edit';
    }
  }
}

/// Result of parsing a free-form voice or text utterance. Mirrors the
/// shape we'd ask a Gemini API to return — so swapping the local
/// heuristic for the real model is a one-file change.
class QuickAddParseResult {
  const QuickAddParseResult({
    required this.intent,
    required this.title,
    required this.fields,
    this.confidence = 0.0,
    this.rationale = '',
  });

  /// Best-guess destination module. [QuickAddIntent.task] is the default
  /// because Bangla utterances about things-to-do are by far the most
  /// common pattern in the seed corpus.
  final QuickAddIntent intent;

  /// User-facing summary that becomes the `title` field on the target
  /// edit screen (transaction title / bill nickname / task title / etc.).
  final String title;

  /// Extracted payload that the destination edit screen consumes. The
  /// shape depends on intent — see parser docs for each.
  final Map<String, Object?> fields;

  /// 0..1 — surfaced as a chip in the preview so the user knows how
  /// sure the parser is before tapping "Go".
  final double confidence;

  /// One-line Bangla/English explanation shown under the preview, e.g.
  /// "matched money keyword + amount".
  final String rationale;
}
