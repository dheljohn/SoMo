// language_provider.dart
import 'package:flutter/foundation.dart';

class LanguageProvider with ChangeNotifier {
  // ← MUST have with ChangeNotifier
  bool _isFilipino = false;

  bool get isFilipino => _isFilipino;

  void toggleLanguage(bool value) {
    _isFilipino = value;
    notifyListeners(); // ← MUST call this
  }
}
