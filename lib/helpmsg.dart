import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:soil_monitoring_app/data_provider.dart';

class HelperMsg extends StatefulWidget {
  const HelperMsg({super.key});

  @override
  State<HelperMsg> createState() => _HelperMsgState();
}

class _HelperMsgState extends State<HelperMsg> {
  int _currentIndex = 0;
  bool _isFilipino = false; // Toggle state for language
  final FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts
  bool _isSpeaking = false; // Flag to track TTS state
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
    });

    //_updateMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMessages(); // Initialize messages
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

    messages.clear(); // Clear existing messages

    if (humidityValue <= 30) {
      addMessage(
        _isFilipino
            ? 'Mababang kahalumigmigan ang nararanasan! Subukang pataasin ang kahalumigmigan.\nRekomendasyon: Maglagay ng mga lagayang may tubig malapit sa mga halaman upang mapataas ang kahalumigmigan. '
            : 'Low Humidity Detected! Consider increasing humidity.\nRecommendation: Place water trays near plants to raise humidity. ', //🌵
        const Color.fromARGB(255, 253, 133, 124),
      );
    } else if (humidityValue >= 70) {
      addMessage(
        _isFilipino
            ? 'Mataas na kahalumigmigan ang nararanasan! Subukang pababain ang kahalumigmigan.\nRekomendasyon: Pagbutihin ang bentilasyon, o iwasan ang sobrang pagdidilig. ' //💦
            : 'High Humidity Detected! Consider decreasing humidity.\nRecommendation: Improve ventilation, or avoid overwatering. ',
        const Color.fromARGB(255, 131, 174, 209),
      );
    }


void checkSensor(String sensorName, double moistureValue) {
  if (moistureValue <= 5) {
    addMessage(
        '$sensorName: Sensor not deployed! ⚠️', 
        const Color.fromARGB(255, 150, 150, 150));
  } else if (moistureValue <= 30) {
    addMessage(
        '$sensorName: Extremely Dry Soil detected! \nRecommendation: Water the soil as needed. 🌱', 
        const Color.fromARGB(255, 253, 133, 124));
  } else if (moistureValue <= 45) {
    addMessage(
        '$sensorName: Well Drained Soil Detected! \nRecommendation: Considering watering soon. 🌱', 
       const Color.fromARGB(255, 236, 188, 66));
   } else if (moistureValue <= 75) {
    addMessage(
        '$sensorName: Moist Soil Detected. \nIdeal Moisture Level. 🌱', 
        const Color.fromARGB(255, 103, 172, 105));
  } else if (moistureValue >= 76) {
    addMessage(
        '$sensorName: Wet Soil Detected! \nRecommendation: Turn Off the Drip line or Skip the next scheduled watering and improve soil drainage. 🚰', 
        const Color.fromARGB(255, 131, 174, 209));
  }
}


    void checkSensor(String sensorName, double moistureValue) {
      if (moistureValue <= 5) {
        addMessage(
          _isFilipino
              ? '$sensorName: Hindi naka-deploy ang sensor! '
              : '$sensorName: Sensor not deployed! ', //⚠️
          const Color.fromARGB(255, 150, 150, 150),
        );
      } else if (moistureValue <= 30) {
        addMessage(
          _isFilipino
              ? '$sensorName: Mababang Moisture ang nararanasan! Isaalang-alang ang pagdidilig ng lupa.\nRekomendasyon: Diligan ang lupa ayon sa pangangailangan. '
              : '$sensorName: Low Moisture Detected! Consider watering the soil.\nRecommendation: Water the soil as needed. ', //🌱
          const Color.fromARGB(255, 253, 133, 124),
        );
      } else if (moistureValue >= 70) {
        addMessage(
          _isFilipino
              ? '$sensorName: Mataas na Moisture ang nararanasan! Isaalang-alang ang pagbabawas ng pagdidilig.\nRekomendasyon: Patayin ang drip line o laktawan ang susunod na nakatakdang pagdidilig at pagbutihin ang drainage ng lupa. ' //🚰
              : '$sensorName: High Moisture Detected! Consider reducing watering.\nRecommendation: Turn off the drip line or skip the next scheduled watering and improve soil drainage. ',
          const Color.fromARGB(255, 131, 174, 209),
        );
      }
    }

    checkSensor(_isFilipino ? 'Sensor 1' : 'Sensor 1', moistureS1);
    checkSensor(_isFilipino ? 'Sensor 2' : 'Sensor 2', moistureS2);
    checkSensor(_isFilipino ? 'Sensor 3' : 'Sensor 3', moistureS3);
    checkSensor(_isFilipino ? 'Sensor 4' : 'Sensor 4', moistureS4);
  }

  void addMessage(String text, Color color) {
    if (!_isSpeaking) {
      setState(() {
        messages.add({'text': text, 'color': color});
      });
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop(); // Stop any ongoing TTS
    await flutterTts.setLanguage(_isFilipino ? 'fil-PH' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
        ),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'No warnings detected!',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                )
              : CarouselSlider.builder(
                  itemCount: messages.length,
                  options: CarouselOptions(
                    height: 140, // Adjust height based on message length
                    scrollDirection: Axis.vertical,
                    autoPlay:
                        !_isSpeaking, // Control autoPlay based on TTS state
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
            Row(
              children: [
                Text('Eng'),
                Switch(
                  value: _isFilipino,
                  activeColor: Color.fromARGB(255, 42, 83, 39),
                  onChanged: (value) {
                    setState(() {
                      _isFilipino = value;
                      _updateMessages(); // Update messages when language is toggled
                    });
                  },
                ),
                Text('Fil'),
                // IconButton(
                //   icon: Icon(Icons.volume_up, color: Colors.black),
                //   onPressed: () async {
                //     if (messages.isNotEmpty) {
                //       await _speak(messages[_currentIndex]['text']);
                //     }
                //   },
                // ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
