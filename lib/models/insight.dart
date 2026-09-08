/// A "Bondhu insight" — the AI-predicted nudges shown on the home dashboard.
///
/// In Phase 3 these will be generated server-side from behaviour history;
/// for now we ship one example so the UI is wired and demo-ready.
class Insight {
  final String id;
  final String titleKey; // ARB key for localized title
  final String bodyTemplateKey; // ARB key with {day} placeholder
  final String primaryActionKey;
  final String dismissActionKey;
  final int dayOfMonth;

  const Insight({
    required this.id,
    required this.titleKey,
    required this.bodyTemplateKey,
    required this.primaryActionKey,
    required this.dismissActionKey,
    required this.dayOfMonth,
  });

  /// Convenience accessor so the home screen doesn't have to know ARB key names.
  String get dayKey => dayOfMonth.toString();
  String get body => bodyTemplateKey;
}