import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/tts_provider.dart';

class HelperMsg extends StatefulWidget {
  final DataProvider dataProvider;

  final String selectedPlot; // Accept selectedPlot

  const HelperMsg(
      {required this.dataProvider, required this.selectedPlot, Key? key})
      : super(key: key);
  @override
  State<HelperMsg> createState() => _HelperMsgState();
}

class _HelperMsgState extends State<HelperMsg> {
  int _currentIndex = 0;

  Map<String, List<int>> moistureLevels = {
    'Lettuce': [60, 80],
    'Pechay': [50, 70],
    'Mustard': [40, 60],
  };

  // bool isFilipino = globalSwitchController.value; // Toggle state for language
  final FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts
  // final TtsProvider ttsProvider =
  //     Provider.of<TtsProvider>(context, listen: false);
  TtsProvider? ttsProvider; // Nullable to prevent initialization errors

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    flutterTts.setStartHandler(() {
      ttsProvider?.setActive(true); // Use null check to avoid errors
    });

    flutterTts.setCompletionHandler(() {
      ttsProvider?.setActive(false);
    });

    flutterTts.setErrorHandler((msg) {
      ttsProvider?.setActive(false);
    });
  }

  @override
  void didUpdateWidget(covariant HelperMsg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlot != widget.selectedPlot) {
      setState(() {}); // Refresh UI when plot changes
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ttsProvider ??=
        Provider.of<TtsProvider>(context, listen: false); // Initialize once

    setState(() {
      _updateMessages();
    });
    _updateMessages();
  }

  void _updateMessages() {
    final dataProvider = DataProvider.of(context);
    final humidityValue = dataProvider?.humidityValue ?? 0.0;
    final temperatureValue = dataProvider?.temperatureValue ?? 0.0;
    final moistureA = dataProvider?.moistureA ?? 0.0;
    final moistureS1 = dataProvider?.moistureS1 ?? 0.0;
    final moistureS2 = dataProvider?.moistureS2 ?? 0.0;
    final moistureS3 = dataProvider?.moistureS3 ?? 0.0;
    final moistureS4 = dataProvider?.moistureS4 ?? 0.0;
    final provider = context.read<LanguageProvider>();
    final isFilipino = provider.isFilipino;

    if (ttsProvider?.isSpeaking == true) return; // Prevent message reset

    messages.clear(); // Clear only if TTS is not active

    if (humidityValue <= 40) {
  addMessage(
    isFilipino
        ? 'Masyadong tuyo. Maaaring magdulot ng pagkatuyo ng halaman.'
        : 'Too dry. Can cause plant dehydration.',
    const Color.fromARGB(255, 253, 133, 124),
  );
} else if (humidityValue > 40 && humidityValue <= 70) {
  addMessage(
    isFilipino
        ? 'Katanggap-tanggap. Angkop para sa karamihan ng mga halaman.'
        : 'Accepted. Suitable for most plants.',
    const Color.fromARGB(255, 103, 172, 105),
  );
} else {
  addMessage(
    isFilipino
        ? 'Masyadong mahalumigmig. May panganib ng fungal growth at sobrang pagdidilig.'
        : 'Too moist. Risk of fungal growth and overwatering.',
    const Color.fromARGB(255, 131, 174, 209),
  );
}

    if (temperatureValue <= 18) { 
  addMessage(
      isFilipino
          ? 'Malamig. Panganib ng frost damage. Protektahan ang mga pananim gamit ang takip.'
          : 'Cold. Risk of frost damage. Protect crops with covers.',
      Colors.blue[300] ?? Colors.blue);
} else if (temperatureValue > 18 && temperatureValue <= 23) {
  addMessage(
      isFilipino
          ? 'Komportable. Perpektong temperatura para sa karamihan ng mga pananim.'
          : 'Comfortable. Ideal temperature for most crops.',
      Colors.green[400] ?? Colors.green);
} else if (temperatureValue > 23 && temperatureValue <= 29) {
  addMessage(
      isFilipino
          ? 'Mainit. Magandang kundisyon ng paglago, ngunit bantayan ang moisture ng lupa.'
          : 'Warm. Good growth conditions, but monitor soil moisture.',
      Colors.orange[300] ?? Colors.orange);
} else if (temperatureValue > 29 && temperatureValue <= 35) {
  addMessage(
      isFilipino
          ? 'Napakainit. Maaaring makaranas ng heat stress ang mga pananim. Siguraduhin ang tamang pagdidilig.'
          : 'Hot. Crops may experience heat stress. Ensure proper irrigation.',
      Colors.red[300] ?? Colors.red);
} else {
  addMessage(
      isFilipino
          ? 'Sobrang init. Mataas ang panganib ng pagkatuyo at pagkasira ng pananim. Magbigay ng lilim at tubig.'
          : 'Very hot. High risk of dehydration and crop damage. Provide shade and water.',
      Colors.red[700] ?? Colors.red);
}

    void checkSensor(String sensorName, double moistureValue) {
      List<int> idealRange =
          moistureLevels[widget.selectedPlot ?? 'Lettuce'] ?? [50, 70];

      if (moistureValue < 8) {
        addMessage(
          isFilipino
              ? '$sensorName: Hindi pa naka-deploy! ⚠️'
              : '$sensorName: Sensor not deployed! ⚠️', //⚠️
          const Color.fromARGB(255, 150, 150, 150),
        );
      } else if (moistureValue <= 29) {
        addMessage(
            isFilipino
                ? '$sensorName: Lubhang Tuyong Lupa ang Nahanap! \nMungkahi: Magdilig upang mapanatili ang tamang kahalumigmigan. 🌱'
                : '$sensorName: Extremely Dry Soil detected! \nRecommendation: Water the soil as needed. 🌱',
            const Color.fromARGB(255, 253, 133, 124));
      } else if (moistureValue < idealRange[0]) {
        addMessage(
            isFilipino
                ? '$sensorName: Maayos na Natutuyong Lupa! \nRekomendasyon: Isaalang-alang ang pagdidilig sa lalong madaling panahon.🌱'
                : '$sensorName: Well Drained Soil Detected! \nRecommendation: Considering watering soon. 🌱',
            const Color.fromARGB(255, 236, 188, 66));
      } else if (moistureValue > idealRange[1]) {
        addMessage(
            isFilipino
                ? '$sensorName: Sobrang Basa ang Lupa! \nRekomendasyon: Huwag munang magdilig, patayin ang drip line, at ayusin ang daluyan ng tubig. 🚰'
                : '$sensorName: Wet Soil Detected! \nRecommendation: Turn Off the Drip line or Skip the next scheduled watering and improve soil drainage. 🚰',
            const Color.fromARGB(255, 131, 174, 209));
      } else {
        addMessage(
            isFilipino
                ? '$sensorName: Mamasa-masang Lupa.\Ideal na Antas ng Moisture. 🌱'
                : '$sensorName: Moist Soil Detected. \nIdeal Moisture Level. 🌱',
            const Color.fromARGB(255, 103, 172, 105));
      }
    }

    checkSensor(isFilipino ? 'Pang-unang sensor' : 'Sensor 1', moistureS1);
    checkSensor(isFilipino ? 'Pangalawang sensor' : 'Sensor 2', moistureS2);
    checkSensor(isFilipino ? 'Pangatlong sensor' : 'Sensor 3', moistureS3);
    checkSensor(isFilipino ? 'Pang-apat na sensor' : 'Sensor 4', moistureS4);
  }

  void addMessage(String text, Color color) {
    if (ttsProvider?.isSpeaking == false) {
      // Null-safe check
      setState(() {
        messages.add({'text': text, 'color': color});
      });
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    ttsProvider?.setActive(true);
    await flutterTts.speak(text);
    // Keep the current slide while speaking
  }

  @override
  Widget build(BuildContext context) {
    bool isFilipino = context.watch<LanguageProvider>().isFilipino;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/somo.png',
                  width: 25,
                  height: 25,
                ),
                const SizedBox(width: 8),
                const Text(
                  "SOMO",
                  style: TextStyle(
                      color: Color.fromARGB(255, 125, 171, 124), fontSize: 17),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up,
                      color: Color.fromARGB(255, 42, 83, 39)),
                  onPressed: () async {
                    if (messages.isNotEmpty) {
                      await _speak(messages[_currentIndex]['text']);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 5.0),
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 5.0),
        // ),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    isFilipino
                        ? 'Walang mga babalang natagpuan!'
                        : 'No warnings detected!',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                )
              : CarouselSlider.builder(
                  itemCount: messages.length,
                  options: CarouselOptions(
                    height: 160, // Adjust height based on message length
                    scrollDirection: Axis.vertical,
                    autoPlay: !context
                        .watch<TtsProvider>()
                        .isSpeaking, // Correct logic
                    pauseAutoPlayOnTouch: true, // Allow manual interaction
                    pauseAutoPlayOnManualNavigate:
                        true, // Pause when manually scrolling
                    pauseAutoPlayInFiniteScroll: true, // Pause on last slide

                    autoPlayInterval: const Duration(seconds: 5),
                    enlargeCenterPage: false,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: messages[index]['color'],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Color.fromARGB(255, 247, 213, 163)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              messages[index]['text'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.040,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
