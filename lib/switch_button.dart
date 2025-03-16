import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:soil_monitoring_app/language_provider.dart'; // Import global switch controller

class SwitchButton extends StatelessWidget {
  const SwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return AdvancedSwitch(
      controller: globalSwitchController, // Use global controller
      activeColor: const Color.fromARGB(255, 42, 83, 39),
      inactiveColor: const Color.fromARGB(255, 42, 83, 39),
      activeChild: const Text('Fil'),
      inactiveChild: const Text('Eng'),
      borderRadius: BorderRadius.circular(15),
      width: 60,
      height: 30,
      onChanged: (value) {
        languageProvider.toggleLanguage(value);
      },
    );
  }
}
