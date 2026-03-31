import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts _tts = FlutterTts();

  TtsHelper() {
    _tts.setLanguage('cs-CZ');
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void dispose() {
    _tts.stop();
  }
}
