import 'package:flutter/material.dart';

import 'severity.dart';

/// Normalized "what's happening today/upcoming" entry for the Home dashboard.
///
/// We don't render `MoneyEntry` / `Bill` / `IdentityDocument` directly on the
/// dashboard — we project them into this small struct so the list view is
/// simple, language-agnostic, and easy to reorder / group.
class HomeItem {
  final String id;
  final ReminderCategory category;
  final String title;
  final String? subtitle;
  final Severity severity;
  final DateTime when;
  final String? personName;
  final double? amount;
  final IconData icon;

  const HomeItem({
    required this.id,
    required this.category,
    required this.title,
    required this.severity,
    required this.when,
    required this.icon,
    this.subtitle,
    this.personName,
    this.amount,
  });

  /// Days from now (negative means overdue). `today` => 0, `tomorrow` => 1.
  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(when.year, when.month, when.day);
    return due.difference(today).inDays;
  }
}