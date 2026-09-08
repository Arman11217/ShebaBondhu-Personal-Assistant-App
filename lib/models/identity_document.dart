enum DocumentType {
  nid,
  passport,
  drivingLicense,
  vehicleFitness,
  tradeLicense,
  bankCard,
  insurance,
  certificate,
  other,
}

extension DocumentTypeX on DocumentType {
  /// Stable lookup key — used by localization tables and analytics.
  String get key {
    switch (this) {
      case DocumentType.nid:
        return 'nid';
      case DocumentType.passport:
        return 'passport';
      case DocumentType.drivingLicense:
        return 'driving_license';
      case DocumentType.vehicleFitness:
        return 'vehicle_fitness';
      case DocumentType.tradeLicense:
        return 'trade_license';
      case DocumentType.bankCard:
        return 'bank_card';
      case DocumentType.insurance:
        return 'insurance';
      case DocumentType.certificate:
        return 'certificate';
      case DocumentType.other:
        return 'other';
    }
  }
}

class IdentityDocument {
  final String id;
  final DocumentType type;
  final String label;
  final String? number;
  final String? issuer;
  final DateTime expiryDate;
  final DateTime? issueDate;
  final String? note;

  const IdentityDocument({
    required this.id,
    required this.type,
    required this.label,
    required this.expiryDate,
    this.issueDate,
    this.number,
    this.issuer,
    this.note,
  });

  IdentityDocument copyWith({
    String? id,
    DocumentType? type,
    String? label,
    String? number,
    String? issuer,
    DateTime? expiryDate,
    DateTime? issueDate,
    String? note,
  }) {
    return IdentityDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      number: number ?? this.number,
      issuer: issuer ?? this.issuer,
      expiryDate: expiryDate ?? this.expiryDate,
      issueDate: issueDate ?? this.issueDate,
      note: note ?? this.note,
    );
  }

  /// Days until expiry. Negative = expired.
  int daysUntilExpiry({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return due.difference(today).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'label': label,
      'number': number,
      'issuer': issuer,
      'expiryDate': expiryDate.toIso8601String(),
      'issueDate': issueDate?.toIso8601String(),
      'note': note,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory IdentityDocument.fromMap(Map<String, dynamic> map, String id) {
    return IdentityDocument(
      id: id,
      type: DocumentType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => DocumentType.nid,
      ),
      label: map['label'] as String? ?? 'ডকুমেন্ট',
      number: map['number'] as String?,
      issuer: map['issuer'] as String?,
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate'] as String) ??
              DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      issueDate: map['issueDate'] != null
          ? DateTime.tryParse(map['issueDate'] as String)
          : null,
      note: map['note'] as String?,
    );
  }
}