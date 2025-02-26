import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';

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
      'Low Humidity Detected! Consider increasing humidity.\nRecommendation: Place water trays near plants to raise humidity.', 
      const Color.fromARGB(255, 253, 133, 124));
} else if (humidityValue >= 70) {
  addMessage(
      'High Humidity Detected! Consider decreasing humidity.\nRecommendation: Improve ventilation,  or avoid overwatering.', 
      const Color.fromARGB(255, 131, 174, 209));
}

if (temperatureValue <= 15) {
  addMessage(
      'Low Temperature Detected! Consider increasing temperature.\nRecommendation: Expose plants to more sunlight.', 
      const Color.fromARGB(255, 131, 174, 209));
} else if (temperatureValue >= 30) {
  addMessage(
      'High Temperature Detected! Consider decreasing temperature.\nRecommendation: Provide shade,  or water plants', 
      const Color.fromARGB(255, 253, 133, 124));
}

if (moistureA <= 30) {
  addMessage(
      'Low Average Moisture Detected! Consider watering the soil.\nRecommendation: Water the soil as needed.', 
      const Color.fromARGB(255, 253, 133, 124));
} else if (moistureA >= 70) {
  addMessage(
      'High Average Moisture Detected! Consider reducing watering.\nRecommendation: Skip the next scheduled watering and ensure proper drainage.', 
      const Color.fromARGB(255, 131, 174, 209));
}

if (moistureS1 <= 30) {
  addMessage(
      'Sensor 1: Low Moisture Detected! Consider watering the soil.\nRecommendation: Water the soil as needed.', 
      const Color.fromARGB(255, 253, 133, 124));
} else if (moistureS1 >= 70) {
  addMessage(
      'Sensor 1: High Moisture Detected! Consider reducing watering.\nRecommendation: Skip the next scheduled watering and improve soil drainage.', 
      const Color.fromARGB(255, 131, 174, 209));
}

if (moistureS2 <= 30) {
 addMessage(
    'Sensor 2: Low Moisture Detected! Consider watering the soil.\nRecommendation: Water the soil as needed.', 
    const Color.fromARGB(255, 253, 133, 124));

} else if (moistureS2 >= 70) {
  addMessage(
      'Sensor 2: High Moisture Detected! Consider reducing watering.\nRecommendation: Skip the next scheduled watering and improve soil drainage.', 
      const Color.fromARGB(255, 131, 174, 209));
}

if (moistureS3 <= 30) {
  addMessage(
      'Sensor 3: Low Moisture Detected! Consider watering the soil.\nRecommendation: Water the soil as needed.', 
      const Color.fromARGB(255, 253, 133, 124));
} else if (moistureS3 >= 70) {
  addMessage(
      'Sensor 3: High Moisture Detected! Consider reducing watering.\nRecommendation: Skip the next scheduled watering to avoid overwatering.', 
      const Color.fromARGB(255, 131, 174, 209));
}

if (moistureS4 <= 30) {
  addMessage(
      'Sensor 4: Low Moisture Detected! Consider watering the soil.\nRecommendation: Water the soil as needed.', 
      const Color.fromARGB(255, 253, 133, 124));
} else if (moistureS4 >= 70) {
  addMessage(
      'Sensor 4: High Moisture Detected! Consider reducing watering.\nRecommendation: Skip the next scheduled watering to prevent waterlogging.', 
      const Color.fromARGB(255, 131, 174, 209));
}


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
                )
              : CarouselSlider.builder(
                  itemCount: messages.length,
                  options: CarouselOptions(
                    height: 100,
                    scrollDirection: Axis.vertical,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
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
                        borderRadius: BorderRadius.circular(8),
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
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
