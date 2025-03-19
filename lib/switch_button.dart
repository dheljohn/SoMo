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

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: AdvancedSwitch(
        controller: globalSwitchController,
        activeColor: const Color.fromARGB(255, 42, 83, 39),
        inactiveColor: const Color.fromARGB(255, 42, 83, 39),
        activeChild: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              'Fil',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.040,
              ),
            )),
        inactiveChild: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              'Eng',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.040,
              ),
            )),
        borderRadius: BorderRadius.circular(15),
        width: MediaQuery.of(context).size.width * 0.170,
        height: MediaQuery.of(context).size.width * 0.0830,
        enabled: !isSpeaking, // Disable when TTS is active
        onChanged: (value) {
          languageProvider.toggleLanguage(value);
        },
      ),
    );
  }
}
