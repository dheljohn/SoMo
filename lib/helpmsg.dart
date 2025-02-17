import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';

class HelperMsg extends StatefulWidget {
  const HelperMsg({super.key});

  @override
  State<HelperMsg> createState() => _HelperMsgState();
}

class _HelperMsgState extends State<HelperMsg> {
  String messageType = 'help'; // Example condition

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

    List<Widget> messageWidgets = [];

    // Helper function to add message with icon and color
    void addMessage(String text, IconData icon, Color color) {
      messageWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: color, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget fixedHeader = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Image.asset(
            'assets/somo.png',
            width: 25,
            height: 25,

            // Fixed header message
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "SOMO",
              style: TextStyle(
                  color: const Color.fromARGB(255, 125, 171, 124),
                  fontSize: 17),
            ),
          ),
        ],
      ),
    );

    // Interpret humidity value
    if (humidityValue <= 30) {
      addMessage('Low Humidity Detected! Consider increasing humidity.',
          Icons.warning, Colors.orange);
    } else if (humidityValue >= 70) {
      addMessage('High Humidity Detected! Consider decreasing humidity.',
          Icons.warning, Colors.orange);
    }

    // Interpret temperature value
    if (temperatureValue <= 15) {
      addMessage('Low Temperature Detected! Consider increasing temperature.',
          Icons.warning, Colors.orange);
    } else if (temperatureValue >= 30) {
      addMessage('High Temperature Detected! Consider decreasing temperature.',
          Icons.warning, Colors.orange);
    }

    // Interpret moisture values
    if (moistureA <= 30) {
      addMessage('Low Average Moisture Detected! Consider watering the soil.',
          Icons.warning, Colors.orange);
    } else if (moistureA >= 70) {
      addMessage('High Average Moisture Detected! Consider reducing watering.',
          Icons.warning, Colors.orange);
    }

    // Interpret individual moisture sensor values
    if (moistureS1 <= 30) {
      addMessage('Sensor 1: Low Moisture Detected! Consider watering the soil.',
          Icons.warning, Colors.orange);
    } else if (moistureS1 >= 70) {
      addMessage(
          'Sensor 1: High Moisture Detected! Consider reducing watering.',
          Icons.warning,
          Colors.orange);
    }

    if (moistureS2 <= 30) {
      addMessage('Sensor 2: Low Moisture Detected! Consider watering the soil.',
          Icons.warning, Colors.orange);
    } else if (moistureS2 >= 70) {
      addMessage(
          'Sensor 2: High Moisture Detected! Consider reducing watering.',
          Icons.warning,
          Colors.orange);
    }

    if (moistureS3 <= 30) {
      addMessage('Sensor 3: Low Moisture Detected! Consider watering the soil.',
          Icons.warning, Colors.orange);
    } else if (moistureS3 >= 70) {
      addMessage(
          'Sensor 3: High Moisture Detected! Consider reducing watering.',
          Icons.warning,
          Colors.orange);
    }

    if (moistureS4 <= 30) {
      addMessage('Sensor 4: Low Moisture Detected! Consider watering the soil.',
          Icons.warning, Colors.orange);
    } else if (moistureS4 >= 70) {
      addMessage(
          'Sensor 4: High Moisture Detected! Consider reducing watering.',
          Icons.warning,
          Colors.orange);
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color.fromARGB(255, 42, 83, 39),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
            bottomRight: Radius.circular(40),
            bottomLeft: Radius.circular(0),
          ),

          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.3),
          //     spreadRadius: 5,
          //     blurRadius: 7,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fixedHeader,
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: messageWidgets,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
