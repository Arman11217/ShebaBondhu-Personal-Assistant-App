/// One medicine in the family stock. Tracks estimated remaining days, dose,
/// and timing slots so Bondhu can schedule reminders.
class Medicine {
  final String id;
  final String name;
  final String forMember;
  final String dose; // e.g. "1 tablet", "5 ml"
  final MedicineFrequency frequency;
  final List<MedicineSlot> slots; // e.g. [morning, afternoon]
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingUnits;
  final int estimatedDaysRemaining;
  final String? note;

  const Medicine({
    required this.id,
    required this.name,
    required this.forMember,
    required this.dose,
    required this.frequency,
    required this.slots,
    required this.remainingUnits,
    required this.estimatedDaysRemaining,
    this.startDate,
    this.endDate,
    this.note,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? forMember,
    String? dose,
    MedicineFrequency? frequency,
    List<MedicineSlot>? slots,
    DateTime? startDate,
    DateTime? endDate,
    int? remainingUnits,
    int? estimatedDaysRemaining,
    String? note,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      forMember: forMember ?? this.forMember,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      slots: slots ?? this.slots,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      remainingUnits: remainingUnits ?? this.remainingUnits,
      estimatedDaysRemaining:
          estimatedDaysRemaining ?? this.estimatedDaysRemaining,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'forMember': forMember,
      'dose': dose,
      'frequency': frequency.name,
      'slots': slots.map((s) => s.name).toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'remainingUnits': remainingUnits,
      'estimatedDaysRemaining': estimatedDaysRemaining,
      'note': note,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String id) {
    final rawSlots = (map['slots'] as List?)?.map((e) => e.toString()) ?? [];
    final parsedSlots = rawSlots.map((s) => MedicineSlot.values.firstWhere(
      (ms) => ms.name == s,
      orElse: () => MedicineSlot.morning,
    )).toList();

    return Medicine(
      id: id,
      name: map['name'] as String? ?? '',
      forMember: map['forMember'] as String? ?? 'আমি',
      dose: map['dose'] as String? ?? '১ টি',
      frequency: MedicineFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
        orElse: () => MedicineFrequency.twiceDaily,
      ),
      slots: parsedSlots.isEmpty ? const [MedicineSlot.morning, MedicineSlot.night] : parsedSlots,
      remainingUnits: (map['remainingUnits'] as num?)?.toInt() ?? 30,
      estimatedDaysRemaining: (map['estimatedDaysRemaining'] as num?)?.toInt() ?? 15,
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate'] as String) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate'] as String) : null,
      note: map['note'] as String?,
    );
  }
}

/// How often a medicine is taken. Drives reminder scheduling and stock
/// burn-down calculations.
enum MedicineFrequency {
  onceDaily,
  twiceDaily,
  thriceDaily,
  fourTimesDaily,
  weekly,
  asNeeded,
}

/// Concrete time-of-day a dose should be taken.
enum MedicineSlot {
  morning,
  afternoon,
  evening,
  night,
}

extension MedicineSlotX on MedicineSlot {
  String get key {
    switch (this) {
      case MedicineSlot.morning:
        return 'morning';
      case MedicineSlot.afternoon:
        return 'afternoon';
      case MedicineSlot.evening:
        return 'evening';
      case MedicineSlot.night:
        return 'night';
    }
  }
}

extension MedicineFrequencyX on MedicineFrequency {
  /// Suggested slots for a given frequency. Used as defaults in the edit form.
  List<MedicineSlot> get defaultSlots {
    switch (this) {
      case MedicineFrequency.onceDaily:
        return [MedicineSlot.morning];
      case MedicineFrequency.twiceDaily:
        return [MedicineSlot.morning, MedicineSlot.evening];
      case MedicineFrequency.thriceDaily:
        return [
          MedicineSlot.morning,
          MedicineSlot.afternoon,
          MedicineSlot.evening
        ];
      case MedicineFrequency.fourTimesDaily:
        return [
          MedicineSlot.morning,
          MedicineSlot.afternoon,
          MedicineSlot.evening,
          MedicineSlot.night
        ];
      case MedicineFrequency.weekly:
        return [MedicineSlot.morning];
      case MedicineFrequency.asNeeded:
        return const [];
    }
  }

  String get key {
    switch (this) {
      case MedicineFrequency.onceDaily:
        return 'once_daily';
      case MedicineFrequency.twiceDaily:
        return 'twice_daily';
      case MedicineFrequency.thriceDaily:
        return 'thrice_daily';
      case MedicineFrequency.fourTimesDaily:
        return 'four_times_daily';
      case MedicineFrequency.weekly:
        return 'weekly';
      case MedicineFrequency.asNeeded:
        return 'as_needed';
    }
  }
}