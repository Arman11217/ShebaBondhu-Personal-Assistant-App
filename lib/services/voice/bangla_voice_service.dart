import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service that speaks out daily summaries and critical reminders in natural Bangla.
class BanglaVoiceService {
  static final BanglaVoiceService _instance = BanglaVoiceService._internal();
  factory BanglaVoiceService() => _instance;
  BanglaVoiceService._internal();

  FlutterTts? _tts;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _tts = FlutterTts();
      await _tts?.setSpeechRate(0.48); // Natural, clear cadence
      await _tts?.setVolume(1.0);
      await _tts?.setPitch(1.0);

      // Try setting Bangladeshi / Bengali voice
      final languages = await _tts?.getLanguages;
      if (languages is List) {
        if (languages.contains('bn-BD') || languages.contains('bn_BD')) {
          await _tts?.setLanguage('bn-BD');
        } else if (languages.any((l) => l.toString().startsWith('bn'))) {
          await _tts?.setLanguage('bn-IN');
        }
      }

      _tts?.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts?.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts?.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  /// Speaks the given text in Bangla.
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    try {
      if (_isSpeaking) {
        await stop();
        return;
      }
      await _tts?.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Stops current speech.
  Future<void> stop() async {
    try {
      await _tts?.stop();
      _isSpeaking = false;
    } catch (_) {}
  }
}
