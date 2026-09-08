import 'package:flutter/foundation.dart';

/// Which Bondhu module the parsed intent refers to.
enum QuickAddModule {
  money,
  bill,
  medicine,
  sim,
  document,
  task,
  unknown;

  static QuickAddModule fromKey(String? key) {
    switch (key) {
      case 'money':
        return QuickAddModule.money;
      case 'bill':
        return QuickAddModule.bill;
      case 'medicine':
        return QuickAddModule.medicine;
      case 'sim':
        return QuickAddModule.sim;
      case 'document':
        return QuickAddModule.document;
      case 'task':
        return QuickAddModule.task;
      default:
        return QuickAddModule.unknown;
    }
  }
}

/// Common shape for any "parsed intent" returned by [GeminiService].
@immutable
class ParsedIntent {
  const ParsedIntent({
    required this.module,
    required this.confidence,
    required this.params,
    this.originalText = '',
  });

  final QuickAddModule module;
  final double confidence;
  final Map<String, Object?> params;
  final String originalText;

  /// Confidence is above the threshold AND module is something we can route.
  bool get isActionable =>
      module != QuickAddModule.unknown && confidence >= 0.4;

  // ----- typed accessors with safe fallbacks ---------------------------

  String? getString(String key) {
    final v = params[key];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  double? getDouble(String key) {
    final v = params[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', ''));
    return null;
  }

  int? getInt(String key) {
    final v = params[key];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  DateTime? getDate(String key) {
    final v = params[key];
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// For display: human readable summary line.
  String summary() {
    switch (module) {
      case QuickAddModule.money:
        final dir = getString('direction') ?? 'paid';
        final amount = getDouble('amount') ?? 0;
        final who = getString('person') ?? '';
        return '${dir == 'receive' ? 'পাবো' : 'দিবো'} ৳${amount.toStringAsFixed(0)}'
            '${who.isNotEmpty ? " ($who)" : ""}';
      case QuickAddModule.bill:
        final type = getString('type') ?? 'bill';
        final amount = getDouble('amount');
        return '$type${amount != null ? " — ৳${amount.toStringAsFixed(0)}" : ""}';
      case QuickAddModule.medicine:
        return getString('name') ?? 'medicine';
      case QuickAddModule.sim:
        final carrier = getString('carrier') ?? '';
        final amount = getDouble('amount');
        return '$carrier${amount != null ? " ৳${amount.toStringAsFixed(0)}" : ""}';
      case QuickAddModule.task:
        final title = getString('title') ?? 'নতুন টাস্ক';
        return 'কাজ: $title';
      case QuickAddModule.document:
        return getString('name') ?? 'নথি';
      case QuickAddModule.unknown:
        return originalText;
    }
  }

  factory ParsedIntent.fromJson(Map<String, Object?> json) {
    return ParsedIntent(
      module: QuickAddModule.fromKey(json['module'] as String?),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      params: (json['params'] as Map?)?.cast<String, Object?>() ?? {},
      originalText: (json['originalText'] as String?) ?? '',
    );
  }

  Map<String, Object?> toJson() => {
        'module': module.name,
        'confidence': confidence,
        'params': params,
        'originalText': originalText,
      };

  @override
  String toString() =>
      'ParsedIntent(module: ${module.name}, confidence: $confidence, params: $params)';
}