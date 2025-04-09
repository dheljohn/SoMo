import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/gauges.dart';
import 'package:soil_monitoring_app/global_switch.dart';
import 'package:soil_monitoring_app/helpmsg.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:soil_monitoring_app/plot_selection_page.dart';
import 'package:soil_monitoring_app/switch_button.dart';
import 'package:soil_monitoring_app/tts_provider.dart';
import 'package:soil_monitoring_app/wifiStat.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DashB extends StatefulWidget {
  const DashB({super.key});

  @override
  State<DashB> createState() => _DashBState();
}

class _DashBState extends State<DashB> with TickerProviderStateMixin {
  bool isFilipino = globalSwitchController.value;
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String? _weather;
  String? _location;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showScrollIndicator = true;
  String? selectedPlot = 'Lettuce'; // Default plot

  void _onPlotChanged(String newPlot) {
    setState(() {
      selectedPlot = newPlot; // Update state when plot changes
    });
  }

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();

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
    globalSwitchController.addListener(() {
      if (mounted) {
        setState(() {
          isFilipino = globalSwitchController.value;
        });
      }
    });
  }

  void _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = DataProvider.of(context);
    final isFilipino = context.watch<LanguageProvider>().isFilipino;

    if (dataProvider == null) {
      return const Text("DataProvider is null");
    }

    return FutureBuilder(
      future: _fApp,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(isFilipino
              ? "Mayroong problema sa firebase"
              : "Something went wrong with firebase");
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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isSpeaking = context.watch<TtsProvider>().isSpeaking;

    // Function to get text color based on value and type
    Color getTextColor(String type, double value) {
      switch (type) {
        case 'humidity':
          return value < 40
              ? const Color.fromARGB(255, 253, 133, 124)
              : value > 70
                  ? const Color.fromARGB(255, 131, 174, 209)
                  : const Color.fromARGB(255, 103, 172, 105);

        case 'temperature':
          return value < 18
              ? const Color.fromARGB(255, 131, 174, 209) // Cold
              : value >= 18 && value <= 23
                  ? const Color.fromARGB(255, 103, 172, 105) // Comfortable
                  : value > 23 && value <= 29
                      ? const Color.fromARGB(255, 255, 183, 77) // Warm
                      : value >= 30 && value <= 35
                          ? const Color.fromARGB(255, 253, 133, 124) // Hot
                          : const Color.fromARGB(
                              255, 198, 40, 40); // Very hot (Sweltering)

        default:
          return Colors.grey;
      }
    }

    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 247, 246, 237),
          padding: EdgeInsets.only(
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              top: screenWidth * 0.04,
              bottom: screenWidth * 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),

                PlotSelection(onPlotChanged: _onPlotChanged),

                SizedBox(height: screenHeight * 0.01),

                // Gauges(dataProvider: dataProvider),
                Gauges(dataProvider: dataProvider, selectedPlot: selectedPlot),

                SizedBox(height: screenHeight * 0.01),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
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
                                '${dataProvider.humidityValue.toInt()}%',
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
                                isFilipino
                                    ? 'Temperatura: '
                                    : '   Temperature: ',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${dataProvider.temperatureValue.toInt()}°C',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: getTextColor('temperature',
                                      dataProvider.temperatureValue),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Icon(
                                Icons.thermostat,
                                color: getTextColor('temperature',
                                    dataProvider.temperatureValue),
                                size: screenWidth * 0.05,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    color: const Color.fromARGB(255, 247, 246, 237),
                    margin: EdgeInsets.all(screenWidth * 0.02),

                    // Adjust height for larger screens
                    //height: screenHeight * .32, // around 35% of screen height
                    width: double.infinity,
                    height: screenHeight > 700
                        ? screenHeight * 0.28
                        : screenHeight * 0.35,

                    child: HelperMsg(
                      key: ValueKey(
                          selectedPlot), // Force rebuild on plot change
                      dataProvider: dataProvider,
                      selectedPlot: selectedPlot!,
                    ),
                  ),
                ),

                //SizedBox(height: screenHeight * 0),
              ],
            ),
          ),
        ),
        WifiStatus(),
        // Positioned(
        //   top: 0,
        //   left: 0,
        //   right: 0,
        //   child: Container(
        //     color: const Color.fromARGB(255, 247, 246, 237),
        //     padding: EdgeInsets.symmetric(
        //         vertical: screenHeight * 0.01, horizontal: screenWidth * 0.05),
        //     child: Center(
        //       child: Text(
        //         'Dashboard',
        //         style: TextStyle(
        //           color: Color.fromARGB(255, 81, 135, 83),
        //           fontSize: screenHeight * 0.027,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ),
        // ), // Add WifiStatus widget to the Stack
      ],
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
