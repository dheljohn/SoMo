import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/tts_provider.dart';

class TextToSpeech {
  final FlutterTts flutterTts = FlutterTts();
  final TtsProvider ttsProvider;

  TextToSpeech(this.ttsProvider) {
    flutterTts.setCompletionHandler(() {
      ttsProvider.setActive(false);
    });
  }

  Future<void> speak(String text) async {
    ttsProvider.setActive(true);
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
    ttsProvider.setActive(false);
  }
}
