import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/gauges.dart';
import 'package:soil_monitoring_app/helpmsg.dart';

class DashB extends StatefulWidget {
  const DashB({super.key});

  @override
  State<DashB> createState() => _DashBState();
}

class _DashBState extends State<DashB> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String? _weather;
  String? _location;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  }
Future<void> _fetchWeather() async {
  try {
    // Step 1: Check Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint("Location Permission Status: $permission");

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      debugPrint("New Location Permission Status: $permission");

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _weather = 'Location permission denied';
        });
        debugPrint("Error: Location permission denied by user");
        return;
      }
    }

    // Step 2: Get Current Position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double lon = position.longitude;

    debugPrint("Fetched Location: Latitude: $lat, Longitude: $lon");

    // Step 3: Call Weather API
    String url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
    debugPrint("Weather API Request URL: $url");

    var response = await http.get(Uri.parse(url));

    // Step 4: Handle API Response
    debugPrint("Weather API Response: ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data.containsKey('current_weather')) {
        int weatherCode = data['current_weather']['weathercode'];
        double temperature = data['current_weather']['temperature'];

        setState(() {
          _weather = '$temperature°C, ${_getWeatherDescription(weatherCode)}';
        });

        debugPrint("Weather Data: $_weather");
      } else {
        setState(() {
          _weather = 'Invalid response from API';
        });  
        debugPrint("Error: Unexpected API response structure");
      }
    } else {
      setState(() {
        _weather = 'Unable to fetch weather';
      });
      debugPrint("Weather API error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    setState(() {
      _weather = 'Error fetching weather';
    });
    debugPrint("Exception occurred: $e");
  }
}

void _showLocationDisabledDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Location Services Disabled"),
        content: const Text("Please enable location services in your device settings to fetch weather updates."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

void _showPermissionDeniedDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Location Permission Denied"),
        content: const Text("This app needs location permission to fetch weather data. Please enable it in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear Sky ☀️';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy 🌤️';
      case 45:
      case 48:
        return 'Foggy 🌫️';
      case 51:
      case 53:
      case 55:
        return 'Drizzle 🌧️';
      case 61:
      case 63:
      case 65:
        return 'Rainy 🌧️';
      case 66:
      case 67:
        return 'Freezing Rain ❄️';
      case 71:
      case 73:
      case 75:
        return 'Snowfall ❄️';
      case 95:
        return 'Thunderstorm ⛈️';
      case 99:
        return 'Heavy Thunderstorm 🌩️';
      default:
        return 'Unknown Weather';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = DataProvider.of(context);
    if (dataProvider == null) {
      return const Text("DataProvider is null");
    }

    return FutureBuilder(
      future: _fApp,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong with firebase");
        } else if (snapshot.hasData) {
          return dashboardMain(dataProvider);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }



Widget dashboardMain(DataProvider dataProvider) {
  // Function to get text color based on value and type
  Color getTextColor(String type, double value) {
    switch (type) {
      case 'humidity':
        return value < 30
            ? Colors.blue
            : value > 70
                ? Colors.orange
                : Colors.green;
      case 'temperature':
        return value < 15
            ? Colors.blue
            : value > 30
                ? Colors.red
                : Colors.green;
      default:
        return Colors.grey;
    }
  }

  return Container(
    color: const Color.fromARGB(255, 247, 246, 237),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 100, 122, 99),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(DateTime.now()), // Date
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE').format(DateTime.now()), // Day
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 2), // Spacing
              // Humidity & Temperature Container
              Container(
                width:170,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 240),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Humidity Section
                    Column(
                      children: [
                        const Text(
                          'Humidity',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: getTextColor('humidity', dataProvider.humidityValue),
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${dataProvider.humidityValue}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: getTextColor('humidity', dataProvider.humidityValue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 2), // Spacing
                    // Temperature Section
                    Column(
                      children: [
                        const Text(
                          'Temperature',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: getTextColor('temperature', dataProvider.temperatureValue),
                              size: 20,
                            ),
                            const SizedBox(width: 1),
                            Text(
                              '${dataProvider.temperatureValue}°C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: getTextColor('temperature', dataProvider.temperatureValue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Gauges Widget
        Gauges(dataProvider: dataProvider),
        const SizedBox(height: 1),
        _soilMoistureGauge(),

        const SizedBox(height: 5),

        Align(
          alignment: Alignment.center,
          child: Container(
            color: const Color.fromARGB(255, 247, 246, 237),
            margin: const EdgeInsets.all(5),
            height: 130,
            width: double.infinity,
            child: const HelperMsg(),
          ),
        ),
      ],
    ),
  );
}

Widget _soilMoistureGauge() {
  return Image.asset(
    'lib/assets/images/image.png',
    width: double.infinity,
    height: 130,
    fit: BoxFit.contain,
  );
}



}
