import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
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

    if (humidityValue <= 39) {
      addMessage(
        isFilipino
            ? 'Masyadong tuyo. Maaaring magdulot ng pagkatuyo ng halaman.'
            : 'Too dry. Can cause plant dehydration.',
        const Color.fromARGB(255, 253, 133, 124),
        Icons.water_drop_outlined,
      );
    } else if (humidityValue >= 40 && humidityValue <= 70) {
      addMessage(
        isFilipino
            ? 'Katanggap-tanggap. Angkop para sa karamihan ng mga halaman.'
            : 'Accepted. Suitable for most plants.',
        const Color.fromARGB(255, 103, 172, 105),
        Icons.check_circle_outline,
      );
    } else {
      addMessage(
        isFilipino
            ? 'Mataas ang humidity. May panganib ng fungal growth at sobrang pagdidilig.'
            : 'High humidity. Risk of fungal growth and overwatering.',
        const Color.fromARGB(255, 131, 174, 209),
        Icons.water_drop_outlined,
      );
    }

    if (temperatureValue < 18) {
      addMessage(
        isFilipino
            ? 'Malamig. Panganib ng frost damage. Protektahan ang mga pananim gamit ang angkop na cover.'
            : 'Cold. Risk of frost damage. Protect crops with covers.',
        const Color.fromARGB(255, 131, 174, 209),
        Icons.thermostat,
      );
    } else if (temperatureValue >= 18 && temperatureValue <= 23) {
      addMessage(
        isFilipino
            ? 'Komportable. Perpektong temperatura para sa karamihan ng mga pananim.'
            : 'Comfortable. Ideal temperature for most crops.',
        Colors.green[400] ?? Colors.green,
        Icons.check_circle_outline,
      );
    } else if (temperatureValue > 23 && temperatureValue <= 29) {
      addMessage(
        isFilipino
            ? 'Mainit. Magandang kundisyon ng paglago, ngunit bantayan ang moisture ng lupa.'
            : 'Warm. Good growth conditions, but monitor soil moisture.',
        Colors.orange[300] ?? Colors.orange,
        Icons.thermostat,
      );
    } else if (temperatureValue > 29 && temperatureValue <= 35) {
      addMessage(
        isFilipino
            ? 'Napakainit. Maaaring makaranas ng heat stress ang mga pananim. Siguraduhin ang tamang pagdidilig.'
            : 'Hot. Crops may experience heat stress. Ensure proper irrigation.',
        Colors.red[300] ?? Colors.red,
        Icons.thermostat,
      );
    } else {
      addMessage(
        isFilipino
            ? 'Sobrang init. Mataas ang panganib ng pagkatuyo at pagkasira ng pananim. Magbigay ng lilim at dilig.'
            : 'Very hot. High risk of dehydration and crop damage. Provide shade and water.',
        Colors.red[700] ?? Colors.red,
        Icons.thermostat,
      );
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
                ? '$sensorName: Malapit ng Matuyo ang Lupa! \nRekomendasyon: Isaalang-alang ang pagdidilig sa lalong madaling panahon.🌱'
                : '$sensorName: Almost Dry Soil! \nRecommendation: Considering watering soon. 🌱',
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
              ? '$sensorName: Mamasa-masang Lupa.\nIdeal na Antas ng Moisture. 🌱'
              : '$sensorName: Moist Soil Detected. \nIdeal Moisture Level. 🌱',
          const Color.fromARGB(255, 103, 172, 105),
          Icons.check_circle_outline,
        );
      }
    }

    checkSensor(isFilipino ? 'Pang-unang sensor' : 'Sensor 1', moistureS1);
    checkSensor(isFilipino ? 'Pangalawang sensor' : 'Sensor 2', moistureS2);
    checkSensor(isFilipino ? 'Pangatlong sensor' : 'Sensor 3', moistureS3);
    checkSensor(isFilipino ? 'Pang-apat na sensor' : 'Sensor 4', moistureS4);
  }

  void addMessage(String text, Color color, [IconData? icon = Icons.warning]) {
    if (ttsProvider?.isSpeaking == false) {
      setState(() {
        messages.add({'text': text, 'color': color, 'icon': icon});
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/somo.png',
                  width: MediaQuery.of(context).size.width * 0.07,
                  height: MediaQuery.of(context).size.width * 0.07,
                  // width: 25,
                  // height: 25,
                ),
                const SizedBox(width: 8),
                Text(
                  "SOMO",
                  style: TextStyle(
                      color: Color.fromARGB(255, 125, 171, 124),
                      fontSize: MediaQuery.of(context).size.width * 0.045),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up,
                      color: Color.fromARGB(255, 42, 83, 39),
                      size: MediaQuery.of(context).size.width * 0.050),
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
        Flexible(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    isFilipino
                        ? 'Walang mga babalang natagpuan!'
                        : 'No warnings detected!',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return CarouselSlider.builder(
                      itemCount: messages.length,
                      options: CarouselOptions(
                        scrollDirection: Axis.vertical,
                        autoPlay: !context.watch<TtsProvider>().isSpeaking,
                        pauseAutoPlayOnTouch: true,
                        pauseAutoPlayOnManualNavigate: true,
                        pauseAutoPlayInFiniteScroll: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        enlargeCenterPage: false,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                        scrollPhysics: ClampingScrollPhysics(),
                        padEnds: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return SizedBox.expand(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              // width: double.infinity,

                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: messages[index]['color'],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    messages[index]['icon'] ?? Icons.warning,
                                    color: Color.fromARGB(255, 247, 213, 163),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      messages[index]['text'],
                                      style: TextStyle(
                                        height: 1.2,
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.040,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
