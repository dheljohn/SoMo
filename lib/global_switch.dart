import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart'; // Add this import

final globalSwitchController = ValueNotifier<bool>(false); // Default to English
// global_state.dart
final ValueNotifier<bool> languageNotifier = ValueNotifier<bool>(false);
