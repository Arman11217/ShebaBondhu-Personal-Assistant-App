import 'dart:ui' show Color;

import '../core/theme/app_colors.dart';

/// Relation to the primary user — drives the avatar icon and accent color.
enum FamilyRelation {
  self,
  spouse,
  father,
  mother,
  son,
  daughter,
  brother,
  sister,
  grandfather,
  grandmother,
  other,
}

extension FamilyRelationX on FamilyRelation {
  String get key {
    switch (this) {
      case FamilyRelation.self:
        return 'self';
      case FamilyRelation.spouse:
        return 'spouse';
      case FamilyRelation.father:
        return 'father';
      case FamilyRelation.mother:
        return 'mother';
      case FamilyRelation.son:
        return 'son';
      case FamilyRelation.daughter:
        return 'daughter';
      case FamilyRelation.brother:
        return 'brother';
      case FamilyRelation.sister:
        return 'sister';
      case FamilyRelation.grandfather:
        return 'grandfather';
      case FamilyRelation.grandmother:
        return 'grandmother';
      case FamilyRelation.other:
        return 'other';
    }
  }
}

/// Common Bangladeshi blood groups.
enum BloodGroup {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  abPositive,
  abNegative,
  oPositive,
  oNegative,
  unknown,
}

extension BloodGroupX on BloodGroup {
  /// Display label, e.g. "A+", "O-".
  String get label {
    switch (this) {
      case BloodGroup.aPositive:
        return 'A+';
      case BloodGroup.aNegative:
        return 'A-';
      case BloodGroup.bPositive:
        return 'B+';
      case BloodGroup.bNegative:
        return 'B-';
      case BloodGroup.abPositive:
        return 'AB+';
      case BloodGroup.abNegative:
        return 'AB-';
      case BloodGroup.oPositive:
        return 'O+';
      case BloodGroup.oNegative:
        return 'O-';
      case BloodGroup.unknown:
        return '?';
    }
  }
}

/// One family member. Phone and NID are optional. Birth date is optional
/// (used to show age on the card).
class FamilyMember {
  final String id;
  final String name;
  final FamilyRelation relation;
  final BloodGroup bloodGroup;

  /// Bangladeshi mobile number, e.g. +8801711000000. Display only.
  final String? phone;

  /// National ID number — typically 10/13/17 digits. Display only.
  final String? nid;

  /// Optional date of birth — used to compute age on the list card.
  final DateTime? birthDate;

  /// Optional short note (occupation, address hint, etc.).
  final String? note;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.bloodGroup = BloodGroup.unknown,
    this.phone,
    this.nid,
    this.birthDate,
    this.note,
  });

  FamilyMember copyWith({
    String? id,
    String? name,
    FamilyRelation? relation,
    BloodGroup? bloodGroup,
    String? phone,
    String? nid,
    DateTime? birthDate,
    String? note,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      nid: nid ?? this.nid,
      birthDate: birthDate ?? this.birthDate,
      note: note ?? this.note,
    );
  }

  /// Approximate age in years. Null if birth date is unknown.
  int? get age {
    final bd = birthDate;
    if (bd == null) return null;
    final now = DateTime.now();
    var years = now.year - bd.year;
    final hadBirthday =
        now.month > bd.month || (now.month == bd.month && now.day >= bd.day);
    if (!hadBirthday) years--;
    if (years < 0) return null;
    return years;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation.key,
      'bloodGroup': bloodGroup.name,
      'phone': phone,
      'nid': nid,
      'birthDate': birthDate?.toIso8601String(),
      'note': note,
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map, String id) {
    FamilyRelation rel = FamilyRelation.other;
    for (final r in FamilyRelation.values) {
      if (r.key == map['relation'] || r.name == map['relation']) {
        rel = r;
        break;
      }
    }
    BloodGroup bg = BloodGroup.unknown;
    for (final b in BloodGroup.values) {
      if (b.name == map['bloodGroup']) {
        bg = b;
        break;
      }
    }
    DateTime? bd;
    if (map['birthDate'] != null) {
      bd = DateTime.tryParse(map['birthDate'].toString());
    }
    return FamilyMember(
      id: id,
      name: map['name'] as String? ?? '',
      relation: rel,
      bloodGroup: bg,
      phone: map['phone'] as String?,
      nid: map['nid'] as String?,
      birthDate: bd,
      note: map['note'] as String?,
    );
  }
}

/// Accent color per relation — used for the avatar tile.
Color relationColor(FamilyRelation r) {
  switch (r) {
    case FamilyRelation.self:
      return AppColors.brandGreen;
    case FamilyRelation.spouse:
      return AppColors.important;
    case FamilyRelation.father:
    case FamilyRelation.grandfather:
      return AppColors.brandGreenDark;
    case FamilyRelation.mother:
    case FamilyRelation.grandmother:
      return AppColors.accent;
    case FamilyRelation.son:
    case FamilyRelation.brother:
      return AppColors.accent;
    case FamilyRelation.daughter:
    case FamilyRelation.sister:
      return AppColors.important;
    case FamilyRelation.other:
      return AppColors.inkMuted;
  }
}

/// First character of the name, capitalized — used for the avatar.
String avatarInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, 1).toUpperCase();
}