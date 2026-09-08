import 'recurring.dart';
import 'severity.dart';

enum MoneyDirection {
  /// Someone owes me / I should receive.
  receive,

  /// I owe someone / I should pay.
  pay,
}

class MoneyEntry {
  final String id;
  final String person;
  final double amount;
  final DateTime dueDate;
  final MoneyDirection direction;
  final Severity severity;
  final Recurring recurring;
  final String? note;
  final String? phoneNumber;

  const MoneyEntry({
    required this.id,
    required this.person,
    required this.amount,
    required this.dueDate,
    required this.direction,
    this.severity = Severity.normal,
    this.recurring = Recurring.none,
    this.note,
    this.phoneNumber,
  });

  MoneyEntry copyWith({
    String? id,
    String? person,
    double? amount,
    DateTime? dueDate,
    MoneyDirection? direction,
    Severity? severity,
    Recurring? recurring,
    String? note,
    String? phoneNumber,
  }) {
    return MoneyEntry(
      id: id ?? this.id,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      direction: direction ?? this.direction,
      severity: severity ?? this.severity,
      recurring: recurring ?? this.recurring,
      note: note ?? this.note,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'person': person,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'direction': direction.name,
      'severity': severity.name,
      'recurring': recurring.name,
      'note': note,
      'phoneNumber': phoneNumber,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory MoneyEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoneyEntry(
      id: id,
      person: map['person'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      direction: map['direction'] == 'pay'
          ? MoneyDirection.pay
          : MoneyDirection.receive,
      severity: Severity.values.firstWhere(
        (s) => s.name == map['severity'],
        orElse: () => Severity.normal,
      ),
      recurring: Recurring.values.firstWhere(
        (r) => r.name == map['recurring'],
        orElse: () => Recurring.none,
      ),
      note: map['note'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
    );
  }
}