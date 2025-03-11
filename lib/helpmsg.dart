import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HelperMsg extends StatefulWidget {
  const HelperMsg({super.key});

  @override
  State<HelperMsg> createState() => _HelperMsgState();
}

class _HelperMsgState extends State<HelperMsg> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dataProvider = DataProvider.of(context);
    final humidityValue = dataProvider?.humidityValue ?? 0.0;
    final temperatureValue = dataProvider?.temperatureValue ?? 0.0;
    final moistureA = dataProvider?.moistureA ?? 0.0;
    final moistureS1 = dataProvider?.moistureS1 ?? 0.0;
    final moistureS2 = dataProvider?.moistureS2 ?? 0.0;
    final moistureS3 = dataProvider?.moistureS3 ?? 0.0;
    final moistureS4 = dataProvider?.moistureS4 ?? 0.0;
List<Map<String, dynamic>> messages = [];

void addMessage(String text, Color color) {
  messages.add({'text': text, 'color': color});
}

if (humidityValue <= 30) {
  addMessage(
      'Low Humidity Detected! Consider increasing humidity.\nRecommendation: Place water trays near plants to raise humidity. 🌵', 
      const Color.fromARGB(255, 253, 133, 124));
} else if (humidityValue >= 70) {
  addMessage(
      'High Humidity Detected! Consider decreasing humidity.\nRecommendation: Improve ventilation, or avoid overwatering. 💦', 
      const Color.fromARGB(255, 131, 174, 209));
}

if (temperatureValue <= 15) {
  addMessage(
      'Low Temperature Detected! Consider increasing temperature.\nRecommendation: Expose plants to more sunlight. ❄️', 
      const Color.fromARGB(255, 131, 174, 209));
} else if (temperatureValue >= 30) {
  addMessage(
      'High Temperature Detected! Consider decreasing temperature.\nRecommendation: Provide shade, or water plants. 🔥', 
      const Color.fromARGB(255, 253, 133, 124));
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


checkSensor('Sensor 1', moistureS1);
checkSensor('Sensor 2', moistureS2);
checkSensor('Sensor 3', moistureS3);
checkSensor('Sensor 4', moistureS4);



    final screenWidth = MediaQuery.of(context).size.width;

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
            height: 100,
            scrollDirection: Axis.vertical,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: false,
            viewportFraction: 3.0,
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
                  const Icon(Icons.warning, color: Color.fromARGB(255, 247, 213, 163)),
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
            children: [
              Image.asset(
                'assets/somo.png',
                width: 25,
                height: 25,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "SOMO",
                  style: TextStyle(
                      color: Color.fromARGB(255, 125, 171, 124), fontSize: 17),
                ),
              ),
            ],
          ),
        
      ],
      
    );
  }
}