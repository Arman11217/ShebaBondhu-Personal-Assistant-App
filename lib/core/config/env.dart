import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads keys from the bundled `.env` file. Initialise once at startup with
/// `await Env.load()` (called from `main.dart`).
class Env {
  Env._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env');
    _loaded = true;
  }

  /// Gemini API key. Empty string when not configured.
  static String get geminiApiKey =>
      dotenv.maybeGet('GEMINI_API_KEY')?.trim() ?? '';

  /// Which Gemini model to use. Defaults to gemini-1.5-flash (fast + cheap).
  static String get geminiModel =>
      dotenv.maybeGet('GEMINI_MODEL')?.trim() ?? 'gemini-1.5-flash';

  /// True if a Gemini key is present.
  static bool get hasGemini => geminiApiKey.isNotEmpty;
}