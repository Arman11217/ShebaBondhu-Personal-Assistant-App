/// How often a reminder repeats. Used by Bill, Recharge, Medicine etc.
enum Recurring {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

extension RecurringX on Recurring {
  /// Returns days between occurrences, or null if [none] / unknown.
  int? get daysBetween {
    switch (this) {
      case Recurring.daily:
        return 1;
      case Recurring.weekly:
        return 7;
      case Recurring.monthly:
        return 30;
      case Recurring.yearly:
        return 365;
      case Recurring.none:
        return null;
    }
  }
}