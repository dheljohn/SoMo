import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;
  final String? selectedPlot;

  Gauges({required this.dataProvider, required this.selectedPlot, Key? key})
      : super(key: key);

  Map<String, List<int>> moistureLevels = {
    'Lettuce': [60, 80],
    'Pechay': [50, 70],
    'Mustard': [40, 60],
  };

  String getWarningMessage(double value) {
    bool isFilipino =
        globalSwitchController.value; // Get the current language state
    List<int> idealRange = moistureLevels[selectedPlot] ?? [50, 70];

    if (value < 8) {
      return isFilipino ? 'Hindi pa naka-deploy' : 'Sensor not deployed';
    } else if (value <= 29) {
      return isFilipino ? 'Matinding tuyong lupa!' : 'Extremely Dry Soil!';
    } else if (value < idealRange[0]) {
      return isFilipino ? 'Magandang pag-drain ng lupa!' : 'Well Drained Soil!';
    } else if (value > idealRange[1]) {
      return isFilipino ? 'Napakabasang lupa!' : 'Wet Soil';
    } else {
      return isFilipino ? 'Basang-basa na lupa' : 'Moist Soil';
    }
  }

  String getRecommendationMessage(double value) {
    //Followed less than 8 strat
    bool isFilipino =
        globalSwitchController.value; // Get the current language state
    List<int> idealRange = moistureLevels[selectedPlot] ?? [50, 70];

    if (value < 8) {
      return isFilipino
          ? 'Walang nadetect na moisture'
          : 'Soil Moisture not detected';
    } else if (value <= 29) {
      return isFilipino
          ? 'Lorem'
          : ' Extremely Dry Soil Detected! \nRecommendation: Water the soil as needed. 🌱';
    } else if (value < idealRange[0]) {
      return isFilipino
          ? 'Lorem'
          : 'Well Drained Soil!\nRecommendation: Considering watering soon.🌱';
    } else if (value > idealRange[1]) {
      return isFilipino
          ? 'Lorem'
          : 'Wet Soil Detected! \nRecommendation: Turn Off the Drip line or Skip the next scheduled watering and improve soil drainage. 🚰';
    } else {
      return isFilipino ? 'Lorem' : 'Moist Soil. \nIdeal Moisture Level. 🌱';
    }
  }

  Color getWarningColor(double value) {
    List<int> idealRange = moistureLevels[selectedPlot] ?? [50, 70];
    if (value < 8) {
      return Colors.grey;
    } else if (value == 15 || value <= 29) {
      return const Color.fromARGB(255, 253, 133, 124);
    } else if (value == 30 || value < idealRange[0]) {
      return const Color.fromARGB(255, 236, 188, 66);
    } else if (value > idealRange[1]) {
      return const Color.fromARGB(255, 131, 174, 209);
    } else {
      return const Color.fromARGB(255, 103, 172, 105);
    }
  }

  void showSensorModal(BuildContext context, String title, double value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            // decoration: BoxDecoration(
            //   border: Border.all(color: Color.fromARGB(255, 42, 83, 39), width: 4),
            //   borderRadius: BorderRadius.circular(10),
            // ),
            padding: EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: getWarningColor(value),
                border: Border.all(
                    color: Color.fromARGB(255, 242, 239, 231), width: 4),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 253, 253, 253),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getRecommendationMessage(value),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 20),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () => Navigator.pop(context),
                  //     child: const Text('Close', style: TextStyle(color: Colors.white)),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildGauge(
      BuildContext context, String title, double value, Color bgColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gaugeSize = screenWidth / 3; // Adjust the divisor to change the size
    final gaugeHeight =
        gaugeSize / 1.2; // Adjust the divisor to change the height

    return GestureDetector(
      onTap: () => showSensorModal(context, title, value),
      child: Container(
        height: gaugeHeight,
        width: gaugeSize,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 42, 83, 39)),
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value >= 9 ? "${value.toInt()}%" : "0%",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.060,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: gaugeSize / 2.9,
                  width: gaugeSize / 2.9,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        radiusFactor: 0.9,
                        showTicks: false,
                        showLabels: false,
                        minimum: 0,
                        maximum: 100,
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: value > 14
                                ? value
                                : 0, // Show 0% if not deployed
                            color: getWarningColor(value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.01,
            ),
            Expanded(
              flex: 2,
              child: Text(
                getWarningMessage(value),

                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.029,
                  fontWeight: FontWeight.bold,
                  color: getWarningColor(value),
                ),
                softWrap: true, // ✅ Allows text to wrap instead of cutting off
                overflow: TextOverflow.visible, // ✅ Ensures text is readable
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // bool isFilipino = context.watch<LanguageProvider>().isFilipino;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: buildGauge(context, 'Soil Moisture S1',
                    dataProvider.moistureS1, Colors.orange.shade50),
              ),
              Expanded(
                child: buildGauge(context, 'Soil Moisture S2',
                    dataProvider.moistureS2, Colors.orange.shade50),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: buildGauge(context, 'Soil Moisture S3',
                    dataProvider.moistureS3, Colors.orange.shade50),
              ),
              Expanded(
                child: buildGauge(context, 'Soil Moisture S4',
                    dataProvider.moistureS4, Colors.orange.shade50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
