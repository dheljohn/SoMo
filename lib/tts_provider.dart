import 'package:flutter/foundation.dart';

class TtsProvider with ChangeNotifier {
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  void setActive(bool value) {
    _isSpeaking = value;
    notifyListeners();
  }
}
