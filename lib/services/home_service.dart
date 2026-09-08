import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../models/home_item.dart';
import '../models/insight.dart';
import '../models/money_entry.dart';
import '../models/severity.dart';
import '../models/sim_card.dart';
import '../models/task.dart';
import 'bill_service.dart';
import 'document_service.dart';
import 'medicine_service.dart';
import 'money_service.dart';
import 'sim_service.dart';
import 'task_service.dart';

/// Aggregates data from every Bondhu module into the unified list the Home
/// dashboard renders.
class HomeService {
  HomeService({
    MoneyService? money,
    BillService? bills,
    DocumentService? documents,
    MedicineService? medicines,
    SimService? sims,
    TaskService? tasks,
  })  : _money = money ?? MoneyService(),
        _bills = bills ?? BillService(),
        _docs = documents ?? DocumentService(),
        _meds = medicines ?? MedicineService(),
        _sims = sims ?? SimService(),
        _tasks = tasks ?? TaskService();

  final MoneyService _money;
  final BillService _bills;
  final DocumentService _docs;
  final MedicineService _meds;
  final SimService _sims;
  final TaskService _tasks;

  List<HomeItem> getAll() => _build();

  /// Items due today or tomorrow, sorted by urgency.
  List<HomeItem> criticalToday() {
    return getAll()
        .where((i) => i.daysUntil <= 1)
        .where((i) =>
            i.severity == Severity.critical ||
            i.severity == Severity.important)
        .toList();
  }

  /// Items further out (2+ days) but worth surfacing.
  List<HomeItem> upcoming() {
    return getAll().where((i) => i.daysUntil > 1).toList();
  }

  List<Insight> activeInsights() {
    final bills = _bills.getAll();
    if (bills.isEmpty) return const [];
    final elec = bills.firstWhere(
      (b) => b.type == BillType.electricity,
      orElse: () => bills.first,
    );
    return [
      Insight(
        id: 'insight-${elec.id}',
        titleKey: 'homeInsightTitle',
        bodyTemplateKey: 'homeInsightBody',
        primaryActionKey: 'homeInsightActionRemind',
        dismissActionKey: 'homeInsightActionDismiss',
        dayOfMonth: elec.nextDueDate.day,
      ),
    ];
  }

  List<HomeItem> _build() {
    final items = <HomeItem>[];

    for (final m in _money.getAll()) {
      items.add(HomeItem(
        id: 'money-${m.id}',
        category: ReminderCategory.money,
        title: m.person,
        icon: Icons.account_balance_wallet_outlined,
        subtitle:
            '\u09F3${m.amount.toStringAsFixed(0)} \u2022 ${_directionLabel(m.direction)}',
        severity: m.severity,
        when: m.dueDate,
        personName: m.person,
        amount: m.amount,
      ));
    }

    for (final b in _bills.getAll()) {
      items.add(HomeItem(
        id: 'bill-${b.id}',
        category: ReminderCategory.bill,
        title: b.label,
        icon: Icons.receipt_long_outlined,
        subtitle:
            '\u09F3${b.amount.toStringAsFixed(0)} \u2022 ${_billTypeLabel(b.type)}',
        severity: _severityForDue(b.nextDueDate),
        when: b.nextDueDate,
        amount: b.amount,
      ));
    }

    for (final d in _docs.getAll()) {
      final days = d.expiryDate.difference(DateTime.now()).inDays;
      items.add(HomeItem(
        id: 'doc-${d.id}',
        category: ReminderCategory.document,
        title: d.label,
        icon: Icons.folder_outlined,
        subtitle: _docSubtitle(days),
        severity: _severityForDaysLeft(days),
        when: d.expiryDate,
      ));
    }

    for (final med in _meds.getAll()) {
      items.add(HomeItem(
        id: 'med-${med.id}',
        category: ReminderCategory.medicine,
        title: med.name,
        icon: Icons.medical_services_outlined,
        subtitle:
            '${med.forMember} \u2022 ${med.estimatedDaysRemaining} days left',
        severity: med.estimatedDaysRemaining <= 4
            ? Severity.important
            : Severity.normal,
        when: DateTime.now().add(Duration(days: med.estimatedDaysRemaining)),
      ));
    }

    for (final s in _sims.getAll()) {
      items.add(HomeItem(
        id: 'sim-${s.id}',
        category: ReminderCategory.recharge,
        title: "${s.memberName}'s SIM",
        icon: Icons.sim_card_outlined,
        subtitle: '${s.carrier} \u2022 ${_simStatusLabel(s.status)}',
        severity: _simSeverity(s.status),
        when: s.packageExpiry ?? DateTime.now().add(const Duration(days: 7)),
      ));
    }

    for (final t in _tasks.getAllSync()) {
      if (t.status == TaskStatus.pending && t.dueDate != null) {
        items.add(HomeItem(
          id: 'task-${t.id}',
          category: ReminderCategory.task,
          title: t.title,
          icon: Icons.check_circle_outline,
          subtitle: t.note ?? 'টাস্ক সম্পন্ন করুন',
          severity: t.priority == TaskPriority.high
              ? Severity.critical
              : Severity.normal,
          when: t.dueDate!,
        ));
      }
    }

    items.sort((a, b) => a.when.compareTo(b.when));
    return items;
  }

  String _directionLabel(MoneyDirection d) =>
      d == MoneyDirection.receive ? 'To receive' : 'To pay';

  String _billTypeLabel(BillType t) {
    switch (t) {
      case BillType.electricity:
        return 'Electricity';
      case BillType.gas:
        return 'Gas';
      case BillType.water:
        return 'Water';
      case BillType.internet:
        return 'Internet';
      case BillType.tv:
        return 'TV / Cable';
      case BillType.mobile:
        return 'Mobile';
      case BillType.other:
        return 'Other';
    }
  }

  String _docSubtitle(int days) {
    if (days <= 0) return 'Expired';
    return '$days days left';
  }

  Severity _severityForDaysLeft(int days) {
    if (days <= 7) return Severity.critical;
    if (days <= 30) return Severity.important;
    return Severity.normal;
  }

  Severity _severityForDue(DateTime due) {
    final diff = due.difference(DateTime.now()).inDays;
    if (diff <= 0) return Severity.critical;
    if (diff <= 1) return Severity.important;
    return Severity.normal;
  }

  Severity _simSeverity(SimStatus s) {
    switch (s) {
      case SimStatus.needsRecharge:
      case SimStatus.dataLow:
        return Severity.critical;
      case SimStatus.packageExpiringSoon:
        return Severity.important;
      case SimStatus.active:
        return Severity.normal;
    }
  }

  String _simStatusLabel(SimStatus s) {
    switch (s) {
      case SimStatus.needsRecharge:
        return 'Recharge recommended';
      case SimStatus.dataLow:
        return 'Data low';
      case SimStatus.packageExpiringSoon:
        return 'Package expiring soon';
      case SimStatus.active:
        return 'Active';
    }
  }
}
