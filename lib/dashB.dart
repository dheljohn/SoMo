import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/gauges.dart';
import 'package:soil_monitoring_app/helpmsg.dart';
import 'package:soil_monitoring_app/plot_selection_page.dart';

class DashB extends StatefulWidget {
  const DashB({super.key});

  @override
  State<DashB> createState() => _DashBState();
}

class _DashBState extends State<DashB> with TickerProviderStateMixin {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String? _weather;
  String? _location;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showScrollIndicator = true;
  String? selectedPlot;

  @override
  void initState() {
    super.initState();
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("SelectedPlot/plotName");

    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          selectedPlot = data.toString();
        });
      } else {
        print("No data found in Firebase!");
      }
    }, onError: (error) {
      print("Firebase error: $error");
    });

    // _fetchWeather();

    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(_animationController);

    // Hide scroll indicator after 4 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showScrollIndicator = true;
        });
      }
    });
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
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

  void _showPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    String correctPassword = "12345"; // Set your password here

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without input
      builder: (context) => AlertDialog(
        title: Text(
          "Enter Password Before Modifying the Plot",
        ),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(hintText: "Password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text == correctPassword) {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlotSelection()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Incorrect password!")),
                );
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
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
          return dashboardMain(dataProvider, context);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget dashboardMain(DataProvider dataProvider, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Function to get text color based on value and type
    Color getTextColor(String type, double value) {
      switch (type) {
        case 'humidity':
          return value < 30
              ? const Color.fromARGB(255, 131, 174, 209)
              : value > 70
                  ? Colors.orange
                  : const Color.fromARGB(255, 103, 172, 105);
        case 'temperature':
          return value < 15
              ? const Color.fromARGB(255, 131, 174, 209)
              : value > 30
                  ? const Color.fromARGB(255, 253, 133, 124)
                  : const Color.fromARGB(255, 103, 172, 105);
        default:
          return Colors.grey;
      }
    }

    return Container(
      color: const Color.fromARGB(255, 247, 246, 237),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            // Date Container
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 138, 167, 136),
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
                // Changed from Column to Row for two-column layout
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          DateFormat('EEEE').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(width: screenWidth * 0.04), // Spacing between columns
                  // Right Column

                  //ADDED THE PLOT HEREEE
                  PlotSelection(),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // SizedBox(height: screenHeight * 0.01),
            // PlotSelection(),
            SizedBox(height: screenHeight * 0.01),
            Gauges(dataProvider: dataProvider),

            SizedBox(height: screenHeight * 0.01),
            Center(
              child: Container(
                width: screenWidth * 0.85,
                padding: EdgeInsets.all(screenWidth * 0.03),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Humidity: ',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${dataProvider.humidityValue}%',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: getTextColor(
                                'humidity', dataProvider.humidityValue),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Icon(
                          Icons.water_drop,
                          color: getTextColor(
                              'humidity', dataProvider.humidityValue),
                          size: screenWidth * 0.05,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Temperature: ',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${dataProvider.temperatureValue}°C',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: getTextColor(
                                'temperature', dataProvider.temperatureValue),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Icon(
                          Icons.thermostat,
                          color: getTextColor(
                              'temperature', dataProvider.temperatureValue),
                          size: screenWidth * 0.05,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                color: const Color.fromARGB(255, 247, 246, 237),
                margin: EdgeInsets.all(screenWidth * 0.02),
                height: screenHeight * 0.15,
                width: double.infinity,
                child: const HelperMsg(),
              ),
            ),
            SizedBox(height: screenHeight * 0.0),
          ],
        ),
      ),
    );
  }

  Widget _soilMoistureGauge(double screenWidth) {
    return Image.asset(
      'lib/assets/images/image.png',
      width: screenWidth * 0.9,
      height: 130,
      fit: BoxFit.contain,
    );
  }
}
