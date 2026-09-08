import 'dart:ui' show Color;

/// Family-wide SIM status, surfaced on the Home dashboard and used to
/// drive urgency color in the Recharge module.
enum SimStatus {
  active,
  dataLow,
  packageExpiringSoon,
  needsRecharge,
}

extension SimStatusX on SimStatus {
  /// Stable string key used for i18n lookup and persistence.
  String get key {
    switch (this) {
      case SimStatus.active:
        return 'active';
      case SimStatus.dataLow:
        return 'dataLow';
      case SimStatus.packageExpiringSoon:
        return 'packageExpiringSoon';
      case SimStatus.needsRecharge:
        return 'needsRecharge';
    }
  }
}

/// Common Bangladeshi mobile carriers. Drives icon + color in the list.
enum SimCarrier {
  grameenphone,
  robi,
  airtel,
  banglalink,
  teletalk,
  other,
}

extension SimCarrierX on SimCarrier {
  String get key {
    switch (this) {
      case SimCarrier.grameenphone:
        return 'grameenphone';
      case SimCarrier.robi:
        return 'robi';
      case SimCarrier.airtel:
        return 'airtel';
      case SimCarrier.banglalink:
        return 'banglalink';
      case SimCarrier.teletalk:
        return 'teletalk';
      case SimCarrier.other:
        return 'other';
    }
  }

  /// Brand color used for the icon tile. Sourced from each carrier's
  /// public brand palette so the UI feels familiar.
  Color get color {
    switch (this) {
      case SimCarrier.grameenphone:
        return const Color(0xFF00A0E2);
      case SimCarrier.robi:
        return const Color(0xFFE2231A);
      case SimCarrier.airtel:
        return const Color(0xFFE60000);
      case SimCarrier.banglalink:
        return const Color(0xFFFF6F00);
      case SimCarrier.teletalk:
        return const Color(0xFF0E7C3A);
      case SimCarrier.other:
        return const Color(0xFF6B7280);
    }
  }
}

/// One family member's SIM card. Carries the carrier, last recharge
/// information, current package validity and remaining data.
class SimCard {
  final String id;
  final String memberName;
  final SimCarrier carrier;
  final String number;

  /// Last recharge date — drives the days-since-last calculation and the
  /// home dashboard's "X days ago" subtitle.
  final DateTime? lastRechargeDate;

  /// BDT amount of the last recharge (display only).
  final double rechargeAmount;

  /// Package validity in days from the last recharge. Used together with
  /// `lastRechargeDate` to compute when the package will expire.
  final int validityDays;

  /// Remaining data balance in GB. Null if the user has not tracked it.
  final double? dataBalanceGb;

  /// Optional note shown on the list card.
  final String? note;

  /// Cached status. The repository computes this from the live values
  /// (dataBalanceGb, validityDays, etc.) and writes it back so the UI
  /// doesn't have to recompute on every rebuild.
  final SimStatus status;

  const SimCard({
    required this.id,
    required this.memberName,
    required this.carrier,
    required this.number,
    this.lastRechargeDate,
    this.rechargeAmount = 0,
    this.validityDays = 30,
    this.dataBalanceGb,
    this.note,
    this.status = SimStatus.active,
  });

  SimCard copyWith({
    String? id,
    String? memberName,
    SimCarrier? carrier,
    String? number,
    DateTime? lastRechargeDate,
    double? rechargeAmount,
    int? validityDays,
    double? dataBalanceGb,
    String? note,
    SimStatus? status,
  }) {
    return SimCard(
      id: id ?? this.id,
      memberName: memberName ?? this.memberName,
      carrier: carrier ?? this.carrier,
      number: number ?? this.number,
      lastRechargeDate: lastRechargeDate ?? this.lastRechargeDate,
      rechargeAmount: rechargeAmount ?? this.rechargeAmount,
      validityDays: validityDays ?? this.validityDays,
      dataBalanceGb: dataBalanceGb ?? this.dataBalanceGb,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  /// Estimated days until the current package expires. Negative if the
  /// package has already run out. Returns null if [lastRechargeDate] is
  /// missing.
  int? get daysUntilExpiry {
    final last = lastRechargeDate;
    if (last == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(last.year, last.month, last.day)
        .add(Duration(days: validityDays));
    return expiry.difference(today).inDays;
  }

  /// The DateTime the current package expires (last recharge + validity).
  /// Null when no recharge has been recorded yet. Used by the home
  /// dashboard to schedule a reminder.
  DateTime? get packageExpiry {
    final last = lastRechargeDate;
    if (last == null) return null;
    return DateTime(last.year, last.month, last.day)
        .add(Duration(days: validityDays));
  }

  Map<String, dynamic> toMap() {
    return {
      'memberName': memberName,
      'carrier': carrier.name,
      'number': number,
      'lastRechargeDate': lastRechargeDate?.toIso8601String(),
      'rechargeAmount': rechargeAmount,
      'validityDays': validityDays,
      'dataBalanceGb': dataBalanceGb,
      'note': note,
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory SimCard.fromMap(Map<String, dynamic> map, String id) {
    final lastRecharge = map['lastRechargeDate'] != null
        ? DateTime.tryParse(map['lastRechargeDate'] as String)
        : null;
    final validity = (map['validityDays'] as num?)?.toInt() ?? 30;
    final dataGb = (map['dataBalanceGb'] as num?)?.toDouble();

    return SimCard(
      id: id,
      memberName: map['memberName'] as String? ?? 'আমি',
      carrier: SimCarrier.values.firstWhere(
        (c) =>
            c.name == map['carrier'] ||
            (c == SimCarrier.airtel &&
                (map['carrier'] == 'cirkle' || map['carrier'] == 'airtel')),
        orElse: () => SimCarrier.grameenphone,
      ),
      number: map['number'] as String? ?? '',
      lastRechargeDate: lastRecharge,
      rechargeAmount: (map['rechargeAmount'] as num?)?.toDouble() ?? 0.0,
      validityDays: validity,
      dataBalanceGb: dataGb,
      note: map['note'] as String?,
      status: computeSimStatus(
        lastRechargeDate: lastRecharge,
        validityDays: validity,
        dataBalanceGb: dataGb,
      ),
    );
  }
}

/// Computes a [SimStatus] from raw SIM fields. Used by the repository
/// when materializing seed entries and on every write.
SimStatus computeSimStatus({
  DateTime? lastRechargeDate,
  int validityDays = 30,
  double? dataBalanceGb,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // No recharge recorded -> assume the SIM is due.
  if (lastRechargeDate == null) {
    return SimStatus.needsRecharge;
  }

  // Package validity check first - this is the more urgent signal.
  final expiry = DateTime(
    lastRechargeDate.year,
    lastRechargeDate.month,
    lastRechargeDate.day,
  ).add(Duration(days: validityDays));
  final daysLeft = expiry.difference(today).inDays;
  if (daysLeft <= 1) {
    return SimStatus.packageExpiringSoon;
  }

  // Then check data balance.
  if (dataBalanceGb != null && dataBalanceGb < 1.0) {
    return SimStatus.dataLow;
  }

  return SimStatus.active;
}
