import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../models/ai/parsed_intent.dart';

/// Result wrapper for a parse attempt.
class ParseResult {
  const ParseResult._(this.intent, {this.error});
  final ParsedIntent? intent;
  final String? error;
  bool get isOk => intent != null;
  factory ParseResult.ok(ParsedIntent intent) => ParseResult._(intent);
  factory ParseResult.error(String msg) => ParseResult._(null, error: msg);
}

/// Wrapper around google_generative_ai (Text + Image) + robust heuristic fallback.
/// Works with Gemini API key, and falls back gracefully if offline or key is missing.
class GeminiService {
  GeminiService({
    String? apiKey,
    String? model,
  })  : _apiKey = apiKey ??
            (dotenv.isInitialized ? (dotenv.env['GEMINI_API_KEY'] ?? '') : ''),
        _modelName = model ??
            (dotenv.isInitialized
                ? (dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash')
                : 'gemini-1.5-flash');

  final String _apiKey;
  final String _modelName;

  bool get hasApiKey =>
      _apiKey.isNotEmpty && _apiKey != 'YOUR_GEMINI_API_KEY_HERE';

  static const _systemPrompt = '''
You are "Bondhu", a smart personal assistant parser for Bangladesh.
Convert user input (whether written in Bengali script, Banglish (phonetic Romanized Bengali e.g., "biddut bill dite hobe 500 taka", "rahim er theke 1000 tk pabo"), English, or mixed slang/spelling mistakes) into strict JSON.

Return ONLY a single JSON object with this shape:
{
  "module": one of ["money", "bill", "medicine", "sim", "document", "task", "unknown"],
  "confidence": number between 0 and 1,
  "params": { ... module-specific keys ... }
}

Schema per module:
- money: { "amount": number, "direction": "give"|"receive", "person": string?, "phoneNumber": string?, "note": string?, "dueDate": ISO-date-string? }
  Note:
  "theke pabo / pelam / pabo / owed to me / paona / পাওনা / pacchi / pamu" -> direction: "receive".
  "dite hobe / dilam / dibo / pay / dena / দেনা / deya lagbe / dimu" -> direction: "give".
- bill: { "type": "electricity"|"gas"|"water"|"internet"|"rent"|"other", "amount": number?, "dueDay": number?, "dueDate": ISO-date-string?, "month": number? }
  Types:
  - electricity: "electricity", "current", "biddut", "bijli", "কারেন্ট", "বিদ্যুৎ"
  - gas: "gas", "titas", "গ্যাস"
  - water: "water", "pani", "wasa", "পানি"
  - internet: "internet", "wifi", "net bill", "ওয়াইফাই", "নেট"
  - rent: "rent", "vara", "basha vara", "shop rent", "বাড়ি ভাড়া", "ভাড়া"
- medicine: { "name": string, "dose": string?, "frequency": string?, "times": string[]? }
  Examples: "napa", "paracetamol", "seclo", "tab", "khete hobe", "khabo", "ওষুধ"
- task: { "title": string, "dueDate": ISO-date-string?, "priority": "low"|"normal"|"high" }
  Examples: "korte hobe", "kinte hobe", "bazar korte hobe", "meeting", "কাজ"
- sim: { "member": string?, "carrier": "grameenphone"|"robi"|"cirkle"|"airtel"|"banglalink"|"teletalk"|"other", "amount": number?, "dataGb": number?, "validityDays": number? }
  Examples: "recharge", "mb", "gb", "gp", "robi", "cirkle", "airtel", "bl", "টেলিটক"
- document: { "name": string, "location": string?, "expiresAt": ISO-date-string? }
  Examples: "nid", "passport", "tin", "license", "দলিল", "নথি"
- unknown: {}

Core Semantic & Language Rules:
1. BANGLISH & TYPO RESILIENCE: Users frequently type in Banglish with arbitrary phonetic spellings and typos. Examples:
   - "biddut bil dite hobe 500 tk" -> bill: electricity, amount: 500, direction: give
   - "karent bil dite hobe" -> bill: electricity
   - "hadi re 500 taka dite hobe" -> money: give, person: "Hadi", amount: 500
   - "karim r kach theke 1200 tk pamu" -> money: receive, person: "Karim", amount: 1200
   - "agami kal napa 500 mg khete hobe" -> medicine: name "Napa", dose: "500mg"
   - "kal sokale bajar korte hobe" -> task: title "bajar korte hobe" / "বাজার করতে হবে"
   Always deduce the underlying intent, correct typos mentally, and map to the appropriate module.
2. NUMERALS & WORD NUMBERS: Understand Bengali numerals (০১২৩৪৫৬৭৮৯), English numerals (0-9), and spoken number words (e.g. "ek hazar" = 1000, "duishot" / "dui sho" = 200, "tinsho" = 300, "পাঁচশত" = 500, "der sho" = 150).
3. RELATIVE DATES:
   - "aaj", "ajke", "today", "আজ" -> today
   - "kal", "kalke", "shokal", "tomorrow", "কাল" -> tomorrow
   - "porshu", "পরশু" -> +2 days
   - "agami mas", "samner mas", "next month", "আগামী মাস" -> next month
   - "5 tarikhe", "৫ তারিখে", "5th" -> 5th day of the current or next upcoming month.
4. If the intent clearly matches one of the services, set confidence >= 0.8. If completely gibberish, set confidence < 0.4 and module to "unknown".
5. Output strict JSON only without any markdown quotes, backticks, or explanation.
''';

  GenerativeModel? _model;

  void _ensureModel() {
    if (_model != null || !hasApiKey) return;
    _model = GenerativeModel(model: _modelName, apiKey: _apiKey);
  }

  /// Parse text-only input.
  Future<ParseResult> parse(String text) async {
    return parseMultimodal(text: text);
  }

  /// Parse text, image (bill photo/prescription), or both.
  Future<ParseResult> parseMultimodal({
    String? text,
    Uint8List? imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final cleanText = text?.trim() ?? '';
    final hasImage = imageBytes != null && imageBytes.isNotEmpty;

    if (cleanText.isEmpty && !hasImage) {
      return ParseResult.error('অনুগ্রহ করে কিছু লিখুন বা ছবি দিন।');
    }

    if (hasApiKey) {
      try {
        _ensureModel();
        final parts = <Part>[
          TextPart(_systemPrompt),
          TextPart('Today\'s date: ${DateTime.now().toIso8601String()}'),
        ];

        if (cleanText.isNotEmpty) {
          parts.add(TextPart('User input: $cleanText'));
        }

        if (hasImage) {
          parts.add(DataPart(mimeType, imageBytes));
          parts.add(TextPart(
              'Analyze this image (bill, memo, prescription, or document). Extract key information according to schema.'));
        }

        final response = await _model!.generateContent([Content.multi(parts)]);
        final raw = response.text ?? '';
        final json = _extractJson(raw);
        if (json != null) {
          json['originalText'] = cleanText.isNotEmpty
              ? cleanText
              : (hasImage ? 'ছবি থেকে সংগৃহীত' : '');
          return ParseResult.ok(ParsedIntent.fromJson(json));
        }
        debugPrint('Gemini returned non-JSON: $raw');
      } catch (e, st) {
        debugPrint('Gemini parse failed → falling back. $e\n$st');
      }
    }

    // Heuristic fallback for text
    if (cleanText.isNotEmpty) {
      final intent = _heuristicParse(cleanText);
      if (intent != null && intent.isActionable) {
        return ParseResult.ok(intent);
      }
    }

    if (hasImage && !hasApiKey) {
      return ParseResult.error(
          'ছবি বিশ্লেষণ করার জন্য Gemini API Key প্রয়োজন। অনুগ্রহ করে .env ফাইলে কি (Key) সেট করুন।');
    }

    return ParseResult.error('তথ্যটি বুঝতে পারিনি। অনুগ্রহ করে একটু স্পষ্ট করে বলুন।');
  }

  static Map<String, Object?>? _extractJson(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1 || end < start) return null;
      final body = raw.substring(start, end + 1);
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) return decoded;
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------
  // Heuristic fallback (Bangla + English + Banglish)
  // ---------------------------------------------------------------------

  ParsedIntent? _heuristicParse(String text) {
    final lower = text.toLowerCase();

    // Bill (electricity, gas, water, internet, etc. have clear specific keywords)
    final bill = _parseBillHeuristic(text, lower);
    if (bill != null) return bill;

    // SIM (recharge, gp, robi, etc.)
    final sim = _parseSimHeuristic(text, lower);
    if (sim != null) return sim;

    // Medicine (napa, paracetamol, etc.)
    final med = _parseMedicineHeuristic(text, lower);
    if (med != null) return med;

    // Money (general loan, give/take between persons)
    final money = _parseMoneyHeuristic(text, lower);
    if (money != null) return money;

    // Task
    final task = _parseTaskHeuristic(text, lower);
    if (task != null) return task;

    // Document
    final doc = _parseDocumentHeuristic(text, lower);
    if (doc != null) return doc;

    return ParsedIntent(
      module: QuickAddModule.unknown,
      confidence: 0.0,
      params: {},
      originalText: text,
    );
  }

  static double? _cleanNumber(String raw) {
    final banglaToEn = raw
        .replaceAll('০', '0')
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(banglaToEn);
  }

  static double? _parseAmount(String text) {
    // 1. Prioritize numbers with currency keywords (e.g. 500 taka, 500টাকা, ৳500)
    final taggedRe = RegExp(
      r'(?:৳|\$)\s*([০-৯0-9][০-৯0-9,]*(?:\.[০-৯0-9]+)?)|([০-৯0-9][০-৯0-9,]*(?:\.[০-৯0-9]+)?)\s*(?:৳|\$|tk|taka|টাকা)',
      caseSensitive: false,
    );
    final taggedMatch = taggedRe.firstMatch(text);
    if (taggedMatch != null) {
      final raw = taggedMatch.group(1) ?? taggedMatch.group(2) ?? '';
      return _cleanNumber(raw);
    }

    // 2. Otherwise pick number that isn't a date (avoiding "10 tarikhe")
    final allNumbers = RegExp(
      r'([০-৯0-9][০-৯0-9,]*(?:\.[০-৯0-9]+)?)(?:\s*(tarikh|tarikhe|তারিখ|তারিখে|দিন|din|days?|st|nd|rd|th))?',
      caseSensitive: false,
    ).allMatches(text);

    for (final m in allNumbers) {
      final suffix = m.group(2);
      if (suffix == null || suffix.isEmpty) {
        final raw = m.group(1) ?? '';
        final val = _cleanNumber(raw);
        if (val != null) return val;
      }
    }

    return null;
  }

  static int? _toInteger(String? raw) {
    if (raw == null) return null;
    final enDigits = raw
        .replaceAll('০', '0')
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9')
        .trim();
    return int.tryParse(enDigits);
  }

  static int? _parseDayOfMonth(String text) {
    // 1. Explicitly tagged date (e.g. ১০ তারিখে, 10 tarikhe, 5th, 1st)
    final explicitMatch = RegExp(
      r'([০-৯0-9]{1,2})\s*(?:তারিখ|তারিখে|tarikh|tarikhe|th|st|nd|rd)(?:[\s,.]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (explicitMatch != null) {
      return _toInteger(explicitMatch.group(1));
    }

    // 2. Look for patterns like "মাসের ১০", "masher 10"
    final contextMatch = RegExp(
      r'(?:মাসের|masher|maser)\s*([০-৯0-9]{1,2})(?:[\s,.]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (contextMatch != null) {
      return _toInteger(contextMatch.group(1));
    }

    // 3. Fallback: isolated 1-2 digit number that is NOT currency
    final matches =
        RegExp(r'(?:^|[\s(,])([০-৯0-9]{1,2})(?:[\s,.)]|$)').allMatches(text);
    for (final m in matches) {
      final start = m.end;
      final remainder = text.substring(start).trimLeft().toLowerCase();
      if (!remainder.startsWith('টাকা') &&
          !remainder.startsWith('taka') &&
          !remainder.startsWith('tk') &&
          !remainder.startsWith('৳') &&
          !remainder.startsWith('\$')) {
        final val = _toInteger(m.group(1));
        if (val != null && val >= 1 && val <= 31) {
          return val;
        }
      }
    }
    return null;
  }

  static DateTime? _resolveDueDate(String text) {
    final now = DateTime.now();
    final lower = text.toLowerCase();
    final isNextMonth = lower.contains('agami mas') ||
        lower.contains('আগামী মাস') ||
        lower.contains('samner mas') ||
        lower.contains('সামনের মাস') ||
        lower.contains('porer mas') ||
        lower.contains('পরের মাস') ||
        lower.contains('next month');
    final day = _parseDayOfMonth(text);

    if (isNextMonth) {
      final targetDay = (day != null && day >= 1 && day <= 28) ? day : 1;
      return DateTime(now.year, now.month + 1, targetDay);
    }
    if (lower.contains('কাল') || lower.contains('kal') || lower.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    }
    if (lower.contains('পরশু') || lower.contains('porshu') || lower.contains('day after tomorrow')) {
      return now.add(const Duration(days: 2));
    }
    if (lower.contains('আজ') || lower.contains('aaj') || lower.contains('today')) {
      return now;
    }
    if (day != null) {
      var date = DateTime(now.year, now.month, day);
      if (date.isBefore(now)) {
        date = DateTime(now.year, now.month + 1, day);
      }
      return date;
    }
    return null;
  }

  static String? _extractPerson(String text) {
    final patterns = <RegExp>[
      RegExp(r"([\w\u0980-\u09FF]+)\s*(?:থেকে|theke)\s+", caseSensitive: false),
      RegExp(r"([\w\u0980-\u09FF]+)\s*(?:er কাছে|er kase|er kache|er theke|er থেকে|from|to)\s+",
          caseSensitive: false),
      RegExp(r"([\w\u0980-\u09FF]+)\s*(?:কে|ke)\s+", caseSensitive: false),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(text);
      if (m != null) {
        final p = m.group(1)?.trim();
        if (p != null &&
            !['আগামী', 'agami', 'কাল', 'kal', 'আজ', 'aaj', 'পরশু', 'porshu']
                .contains(p.toLowerCase())) {
          return p;
        }
      }
    }
    return null;
  }

  static String? _extractPhoneNumber(String text) {
    const bnToEn = {
      '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
      '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9',
    };
    var s = text;
    bnToEn.forEach((k, v) => s = s.replaceAll(k, v));
    final match =
        RegExp(r'(?:\+?88)?\s*(01[3-9]\d{2}[-\s]?\d{6})').firstMatch(s);
    if (match != null) {
      return match.group(1)!.replaceAll(RegExp(r'[-\s]'), '');
    }
    return null;
  }

  ParsedIntent? _parseMoneyHeuristic(String text, String lower) {
    final giveWords = [
      'দিলাম', 'দিবো', 'দিতে হবে', 'দিতে হবে', 'dilam', 'dibo', 'dite hobe',
      'ditehobe', 'dite hbe', 'deya lagbe', 'dimu', 'debo', 'paid', 'gave', 'give', 'pay', 'dena', 'দেনা'
    ];
    final receiveWords = [
      'পাবো', 'পাব', 'পেলাম', 'পেলে', 'পাওয়া', 'pabo', 'pelam', 'paona', 'pawa',
      'pamu', 'pacchi', 'got', 'receive', 'owed', 'paona', 'পাওনা'
    ];
    final hasMoney = text.contains('টাকা') ||
        text.contains('taka') ||
        text.contains('টেকা') ||
        text.contains('teka') ||
        text.contains('৳') ||
        text.contains('tk') ||
        RegExp(r'\d').hasMatch(text);

    if (!hasMoney) return null;
    final direction = giveWords.any(lower.contains)
        ? 'give'
        : receiveWords.any(lower.contains)
            ? 'receive'
            : null;
    if (direction == null) return null;

    final amount = _parseAmount(text);
    final person = _extractPerson(text);
    final due = _resolveDueDate(text);
    final phone = _extractPhoneNumber(text);

    return ParsedIntent(
      module: QuickAddModule.money,
      confidence: 0.8,
      params: {
        'amount': amount,
        'direction': direction,
        'person': person,
        'phoneNumber': phone,
        'dueDate': due?.toIso8601String(),
      },
      originalText: text,
    );
  }

  ParsedIntent? _parseBillHeuristic(String text, String lower) {
    final billKeywords = [
      'bill', 'bil', 'বিল', 'electricity', 'electicitu', 'electric', 'biddut',
      'bidduth', 'karent', 'current', 'বিদ্যুৎ', 'কারেন্ট', 'gas', 'গ্যাস',
      'pani', 'water', 'পানি', 'internet', 'wifi', 'ওয়াইফাই', 'rent', 'vara', 'basha vara', 'ভাড়া'
    ];
    if (!billKeywords.any(lower.contains)) return null;

    final type = lower.contains('electricity') ||
            lower.contains('electicitu') ||
            lower.contains('electric') ||
            lower.contains('biddut') ||
            lower.contains('bidduth') ||
            lower.contains('karent') ||
            lower.contains('current') ||
            lower.contains('বিদ্যুৎ') ||
            lower.contains('কারেন্ট')
        ? 'electricity'
        : lower.contains('gas') || lower.contains('গ্যাস')
            ? 'gas'
            : lower.contains('water') || lower.contains('pani') || lower.contains('পানি')
                ? 'water'
                : lower.contains('internet') ||
                        lower.contains('wifi') ||
                        lower.contains('ওয়াইফাই')
                    ? 'internet'
                    : lower.contains('rent') || lower.contains('vara') || lower.contains('ভাড়া')
                        ? 'rent'
                        : 'other';

    final due = _resolveDueDate(text);
    final day = _parseDayOfMonth(text);

    return ParsedIntent(
      module: QuickAddModule.bill,
      confidence: 0.8,
      params: {
        'type': type,
        'amount': _parseAmount(text),
        'dueDay': day ?? due?.day,
        'dueDate': due?.toIso8601String(),
      },
      originalText: text,
    );
  }

  ParsedIntent? _parseSimHeuristic(String text, String lower) {
    final simKeywords = [
      'recharge', 'রিচার্জ', 'gp', 'grameenphone', 'গ্রামীণফোন', 'robi', 'রবি',
      'cirkle', 'সার্কেল', 'airtel', 'এয়ারটেল', 'banglalink', 'বাংলালিংক', 'teletalk', 'টেলিটক'
    ];
    if (!simKeywords.any(lower.contains)) return null;

    final carrier = lower.contains('gp') ||
            lower.contains('grameenphone') ||
            lower.contains('গ্রামীণফোন')
        ? 'grameenphone'
        : lower.contains('robi') || lower.contains('রবি')
            ? 'robi'
            : lower.contains('cirkle') || lower.contains('সার্কেল') || lower.contains('airtel') || lower.contains('এয়ারটেল')
                ? 'airtel'
                : lower.contains('banglalink') || lower.contains('বাংলালিংক')
                    ? 'banglalink'
                    : lower.contains('teletalk') || lower.contains('টেলিটক')
                        ? 'teletalk'
                        : 'other';

    return ParsedIntent(
      module: QuickAddModule.sim,
      confidence: 0.75,
      params: {
        'carrier': carrier,
        'amount': _parseAmount(text),
        'dataGb': _parseAmount(text),
      },
      originalText: text,
    );
  }

  ParsedIntent? _parseMedicineHeuristic(String text, String lower) {
    final medKeywords = [
      'খেতে', 'khete', 'ঔষধ', 'ওষুধ', 'medicine', 'tablet', 'ট্যাবলেট', 'capsule', 'mg'
    ];
    if (!medKeywords.any(lower.contains)) return null;
    final mg = RegExp(r'(\d+)\s*mg').firstMatch(text)?.group(1);
    final name = RegExp(r'([\w\u0980-\u09FF]+)\s*(?:\d|mg|খেতে|khete|ট্যাবলেট|tablet)')
        .firstMatch(text)
        ?.group(1);

    return ParsedIntent(
      module: QuickAddModule.medicine,
      confidence: 0.7,
      params: {
        'name': name ?? text.split(' ').first,
        'dose': mg != null ? '${mg}mg' : null,
      },
      originalText: text,
    );
  }

  ParsedIntent? _parseTaskHeuristic(String text, String lower) {
    final taskKeywords = [
      'task', 'টাস্ক', 'কাজ', 'করতে হবে', 'korte hobe', 'kinte hobe',
      'কিনতে হবে', 'যেতে হবে', 'jete hobe', 'আনতে হবে', 'ante hobe'
    ];
    if (!taskKeywords.any(lower.contains)) return null;

    final due = _resolveDueDate(text);
    return ParsedIntent(
      module: QuickAddModule.task,
      confidence: 0.7,
      params: {
        'title': text,
        'dueDate': due?.toIso8601String(),
        'priority': 'normal',
      },
      originalText: text,
    );
  }

  ParsedIntent? _parseDocumentHeuristic(String text, String lower) {
    final docKeywords = [
      'document', 'ডকুমেন্ট', 'নথি', 'nid', 'জাতীয় পরিচয়পত্র', 'পাসপোর্ট',
      'passport', 'লাইসেন্স', 'license'
    ];
    if (!docKeywords.any(lower.contains)) return null;

    return ParsedIntent(
      module: QuickAddModule.document,
      confidence: 0.65,
      params: {
        'name': text,
      },
      originalText: text,
    );
  }

  /// Convenience helper for tests.
  Future<ParsedIntent> parseOrNull(String text) async {
    final r = await parse(text);
    return r.intent ??
        ParsedIntent(
          module: QuickAddModule.unknown,
          confidence: 0,
          params: {},
          originalText: text,
        );
  }

  // ignore: unused_field
  static final _r = math.Random();
}