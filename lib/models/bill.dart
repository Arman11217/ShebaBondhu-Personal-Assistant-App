import 'recurring.dart';
import 'severity.dart';

/// Type of household bill. Drives icon + label on the Bill module.
enum BillType {
  electricity,
  gas,
  water,
  internet,
  tv,
  mobile,
  other,
}

extension BillTypeX on BillType {
  String get key {
    switch (this) {
      case BillType.electricity:
        return 'electricity';
      case BillType.gas:
        return 'gas';
      case BillType.water:
        return 'water';
      case BillType.internet:
        return 'internet';
      case BillType.tv:
        return 'tv';
      case BillType.mobile:
        return 'mobile';
      case BillType.other:
        return 'other';
    }
  }
}

class Bill {
  final String id;
  final BillType type;
  final String label;
  final String provider;
  final double amount;
  final DateTime nextDueDate;
  final Recurring recurring;
  final Severity severity;
  final bool autoPay;
  final String? note;

  const Bill({
    required this.id,
    required this.type,
    required this.label,
    required this.provider,
    required this.amount,
    required this.nextDueDate,
    this.recurring = Recurring.monthly,
    this.severity = Severity.normal,
    this.autoPay = false,
    this.note,
  });

  Bill copyWith({
    String? id,
    BillType? type,
    String? label,
    String? provider,
    double? amount,
    DateTime? nextDueDate,
    Recurring? recurring,
    Severity? severity,
    bool? autoPay,
    String? note,
  }) {
    return Bill(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      recurring: recurring ?? this.recurring,
      severity: severity ?? this.severity,
      autoPay: autoPay ?? this.autoPay,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'label': label,
      'provider': provider,
      'amount': amount,
      'nextDueDate': nextDueDate.toIso8601String(),
      'recurring': recurring.name,
      'severity': severity.name,
      'autoPay': autoPay,
      'note': note,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map, String id) {
    return Bill(
      id: id,
      type: BillType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => BillType.other,
      ),
      label: map['label'] as String? ?? 'বিল',
      provider: map['provider'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      nextDueDate: map['nextDueDate'] != null
          ? DateTime.tryParse(map['nextDueDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      recurring: Recurring.values.firstWhere(
        (r) => r.name == map['recurring'],
        orElse: () => Recurring.monthly,
      ),
      severity: Severity.values.firstWhere(
        (s) => s.name == map['severity'],
        orElse: () => Severity.normal,
      ),
      autoPay: map['autoPay'] as bool? ?? false,
      note: map['note'] as String?,
    );
  }
}