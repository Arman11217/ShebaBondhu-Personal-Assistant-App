import 'dart:ui' show Color;

import '../core/theme/app_colors.dart';

/// Status of a warranty, used to drive urgency color on the list and the
/// home dashboard.
enum WarrantyStatus {
  active,
  expiringSoon,
  expired,
}

/// Common product categories. Drives icon on the list card.
enum WarrantyCategory {
  electronics,
  appliance,
  furniture,
  vehicle,
  jewellery,
  clothing,
  other,
}

extension WarrantyCategoryX on WarrantyCategory {
  String get key {
    switch (this) {
      case WarrantyCategory.electronics:
        return 'electronics';
      case WarrantyCategory.appliance:
        return 'appliance';
      case WarrantyCategory.furniture:
        return 'furniture';
      case WarrantyCategory.vehicle:
        return 'vehicle';
      case WarrantyCategory.jewellery:
        return 'jewellery';
      case WarrantyCategory.clothing:
        return 'clothing';
      case WarrantyCategory.other:
        return 'other';
    }
  }
}

/// A single product under warranty. Has a purchase date and an expiry date;
/// status is computed live from those dates.
class WarrantyProduct {
  final String id;
  final String productName;

  /// Brand / manufacturer. e.g. "Samsung", "Walton".
  final String brand;

  /// Category drives the list icon and color accent.
  final WarrantyCategory category;

  /// Purchase date — displayed as "Purchased 12 Mar 2024".
  final DateTime purchaseDate;

  /// The date the warranty expires. Drives the urgency chip.
  final DateTime expiryDate;

  /// Optional price — display only.
  final double price;

  /// Optional vendor / shop name.
  final String? vendor;

  /// Optional note (model number, serial, etc.).
  final String? note;

  /// Cached status, recomputed on every write by the repository.
  final WarrantyStatus status;

  const WarrantyProduct({
    required this.id,
    required this.productName,
    required this.brand,
    required this.category,
    required this.purchaseDate,
    required this.expiryDate,
    this.price = 0,
    this.vendor,
    this.note,
    this.status = WarrantyStatus.active,
  });

  WarrantyProduct copyWith({
    String? id,
    String? productName,
    String? brand,
    WarrantyCategory? category,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? price,
    String? vendor,
    String? note,
    WarrantyStatus? status,
  }) {
    return WarrantyProduct(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      price: price ?? this.price,
      vendor: vendor ?? this.vendor,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  /// Days until the warranty expires. Negative if it has already expired.
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    return expiry.difference(today).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'brand': brand,
      'category': category.key,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'price': price,
      'vendor': vendor,
      'note': note,
    };
  }

  factory WarrantyProduct.fromMap(Map<String, dynamic> map, String id) {
    WarrantyCategory cat = WarrantyCategory.other;
    for (final c in WarrantyCategory.values) {
      if (c.key == map['category'] || c.name == map['category']) {
        cat = c;
        break;
      }
    }
    final pDate =
        DateTime.tryParse(map['purchaseDate']?.toString() ?? '') ?? DateTime.now();
    final eDate =
        DateTime.tryParse(map['expiryDate']?.toString() ?? '') ?? DateTime.now();
    return WarrantyProduct(
      id: id,
      productName: map['productName'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      category: cat,
      purchaseDate: pDate,
      expiryDate: eDate,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      vendor: map['vendor'] as String?,
      note: map['note'] as String?,
      status: computeWarrantyStatus(eDate),
    );
  }
}

/// Computes [WarrantyStatus] from the expiry date. Anything inside 30 days
/// is `expiringSoon`; in the past is `expired`; otherwise `active`.
WarrantyStatus computeWarrantyStatus(DateTime expiryDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(
    expiryDate.year,
    expiryDate.month,
    expiryDate.day,
  );
  final diff = expiry.difference(today).inDays;
  if (diff < 0) return WarrantyStatus.expired;
  if (diff <= 30) return WarrantyStatus.expiringSoon;
  return WarrantyStatus.active;
}

/// Accent color per category — used for the list icon tile.
Color categoryColor(WarrantyCategory c) {
  switch (c) {
    case WarrantyCategory.electronics:
      return AppColors.accent;
    case WarrantyCategory.appliance:
      return AppColors.brandGreen;
    case WarrantyCategory.furniture:
      return AppColors.brandGreenDark;
    case WarrantyCategory.vehicle:
      return AppColors.important;
    case WarrantyCategory.jewellery:
      return AppColors.brandGreenDark;
    case WarrantyCategory.clothing:
      return AppColors.accent;
    case WarrantyCategory.other:
      return AppColors.inkMuted;
  }
}
