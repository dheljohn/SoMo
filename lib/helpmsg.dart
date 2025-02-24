import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';

class HelperMsg extends StatelessWidget {
  const HelperMsg({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = DataProvider.of(context);
    final humidityValue = dataProvider?.humidityValue ?? 0.0;
    final temperatureValue = dataProvider?.temperatureValue ?? 0.0;
    final moistureA = dataProvider?.moistureA ?? 0.0;

    Widget fixedHeader = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
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
                color: Color.fromARGB(255, 125, 171, 124),
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );

    List<Widget> messageWidgets = [];

    if (humidityValue <= 30) {
      messageWidgets.add(_buildMessage(
          'Low Humidity Detected! Consider increasing humidity.',
          Icons.warning,
          Colors.orange));
    }
    if (temperatureValue >= 30) {
      messageWidgets.add(_buildMessage(
          'High Temperature Detected! Consider decreasing temperature.',
          Icons.warning,
          Colors.red));
    }
    if (moistureA <= 30) {
      messageWidgets.add(_buildMessage(
          'Low Average Moisture! Consider watering the soil.',
          Icons.warning,
          Colors.blue));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fixedHeader,
          const SizedBox(height: 5),
          if (messageWidgets.isEmpty)
            _buildMessage("No issues detected.", Icons.check_circle, Colors.green)
          else
            Column(children: messageWidgets),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(

          color: Colors.white,
          border: Border.all(
            color: Color.fromARGB(255, 42, 83, 39),
          ),

          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],

        ),
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
}
  