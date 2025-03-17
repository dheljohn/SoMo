// import 'package:soil_monitoring_app/tts_provider.dart';

// class TextToSpeech {
//   final TtsProvider ttsProvider;

//   TextToSpeech(this.ttsProvider);

//   Future<void> speak(String text) async {
//     ttsProvider.setActive(true);
//     await flutterTts.speak(text);
//     // Set up completion handler
//     flutterTts.setCompletionHandler(() {
//       ttsProvider.setActive(false);
//     });
//   }

//   Future<void> stop() async {
//     await flutterTts.stop();
//     ttsProvider.setActive(false);
//   }
// }
