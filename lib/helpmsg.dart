import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/tts_provider.dart';

class HelperMsg extends StatefulWidget {
  const HelperMsg({super.key});

  @override
  State<HelperMsg> createState() => _HelperMsgState();
}

class _HelperMsgState extends State<HelperMsg> {
  int _currentIndex = 0;

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

    if (humidityValue <= 30) {
      addMessage(
        isFilipino
            ? 'Mababang kahalumigmigan ang nararanasan! Subukang pataasin ang kahalumigmigan.\nRekomendasyon: Maglagay ng mga lagayang may tubig malapit sa mga halaman upang mapataas ang kahalumigmigan. '
            : 'Low Humidity Detected! Consider increasing humidity.\nRecommendation: Place water trays near plants to raise humidity. ', //🌵
        const Color.fromARGB(255, 253, 133, 124),
      );
    } else if (humidityValue >= 70) {
      addMessage(
        isFilipino
            ? 'Mataas na kahalumigmigan ang nararanasan! Subukang pababain ang kahalumigmigan.\nRekomendasyon: Pagbutihin ang bentilasyon, o iwasan ang sobrang pagdidilig. ' //💦
            : 'High Humidity Detected! Consider decreasing humidity.\nRecommendation: Improve ventilation, or avoid overwatering. ',
        const Color.fromARGB(255, 131, 174, 209),
      );
    }

    if (temperatureValue <= 15) {
      addMessage(
          isFilipino
              ? 'Mababang temperatura ang na-detect! Subukang pataasin ang temperatura.\nRekomendasyon: Maglagay ng mga lagayang may tubig malapit sa mga halaman upang mapataas ang kahalumigmigan.'
              : 'Low Temperature Detected! Consider increasing temperature.\nRecommendation: Expose plants to more sunlight. ❄️',
          const Color.fromARGB(255, 131, 174, 209));
    } else if (temperatureValue >= 30) {
      addMessage(
          isFilipino
              ? 'Mataas na temperatura ang nararanasan! Subukang pababain ang temperatura.'
              : 'High Temperature Detected! Consider decreasing temperature.\nRecommendation: Provide shade, or water plants. 🔥',
          const Color.fromARGB(255, 253, 133, 124));
    }

    void checkSensor(String sensorName, double moistureValue) {
      if (moistureValue < 15) {
        addMessage(
          isFilipino
              ? '$sensorName: Hindi pa naka-deploy! ⚠️'
              : '$sensorName: Sensor not deployed! ⚠️', //⚠️
          const Color.fromARGB(255, 150, 150, 150),
        );
      } else if (moistureValue <= 29) {
        addMessage(
            isFilipino
                ? 'Lorem'
                : '$sensorName: Extremely Dry Soil detected! \nRecommendation: Water the soil as needed. 🌱',
            const Color.fromARGB(255, 253, 133, 124));
      } else if (moistureValue <= 45) {
        addMessage(
            isFilipino
                ? 'Lorem'
                : '$sensorName: Well Drained Soil Detected! \nRecommendation: Considering watering soon. 🌱',
            const Color.fromARGB(255, 236, 188, 66));
      } else if (moistureValue <= 75) {
        addMessage(
            isFilipino
                ? 'Lorem'
                : '$sensorName: Moist Soil Detected. \nIdeal Moisture Level. 🌱',
            const Color.fromARGB(255, 103, 172, 105));
      } else if (moistureValue >= 76) {
        addMessage(
            isFilipino
                ? 'Lorem'
                : '$sensorName: Wet Soil Detected! \nRecommendation: Turn Off the Drip line or Skip the next scheduled watering and improve soil drainage. 🚰',
            const Color.fromARGB(255, 131, 174, 209));
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
        ),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    isFilipino
                        ? 'Hindi naka-deployed and sensor'
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
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(0),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/somo.png',
                  width: MediaQuery.of(context).size.width * 0.090,
                  height: MediaQuery.of(context).size.width * 0.090,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                Text(
                  "SOMO",
                  style: TextStyle(
                      color: Color.fromARGB(255, 125, 171, 124),
                      fontSize: MediaQuery.of(context).size.width * 0.040),
                ),
                IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: Color.fromARGB(255, 42, 83, 39),
                    size: MediaQuery.of(context).size.width * 0.060,
                  ),
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
      ],
    );
  }
}
