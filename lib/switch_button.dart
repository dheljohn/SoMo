import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:soil_monitoring_app/tts_provider.dart'; // Import global switch controller

class SwitchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isSpeaking = context.watch<TtsProvider>().isSpeaking;


    return AdvancedSwitch(
      controller: globalSwitchController, 
      activeColor: const Color.fromARGB(255, 42, 83, 39),
      inactiveColor: const Color.fromARGB(255, 42, 83, 39),
      activeChild: const Text('Fil', style: TextStyle(fontSize: 18)), 
      inactiveChild: const Text('Eng', style: TextStyle(fontSize: 18)), 
      borderRadius: BorderRadius.circular(20), 
      width: 75, 
      height: 35, 
      onChanged: (value) {
        languageProvider.toggleLanguage(value);
      },

    );
  }
}
