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
// Removed duplicate _requestNotificationPermission method

  void _showNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Enable Notifications"),
        content: Text(
            "This app requires notifications to function properly. Please allow notifications in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestNotificationPermission();
            },
            child: Text("Enable"),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    String formattedDate = DateFormat(' MMMM d, yyyy').format(DateTime.now());

    if (isFilipino) {
      formattedDate = _translateMonth(formattedDate);
    }

    return formattedDate;
  }

  String _getFormattedWeek() {
    String formattedWeek = DateFormat('EEEE').format(DateTime.now());

    if (isFilipino) {
      formattedWeek = _translateWeek(formattedWeek);
    }

    return formattedWeek;
  }

  String _translateMonth(String date) {
    return date.replaceAllMapped(
      RegExp(
          r'January|February|March|April|May|June|July|August|September|October|November|December'),
      (match) {
        return {
          'January': 'Enero',
          'February': 'Pebrero',
          'March': 'Marso',
          'April': 'Abril',
          'May': 'Mayo',
          'June': 'Hunyo',
          'July': 'Hulyo',
          'August': 'Agosto',
          'September': 'Setyembre',
          'October': 'Oktubre',
          'November': 'Nobyembre',
          'December': 'Disyembre',
        }[match[0]]!;
      },
    );
  }

  String _translateWeek(String date) {
    return date.replaceAllMapped(
      RegExp(r'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday'),
      (match) {
        return {
          'Monday': 'Lunes',
          'Tuesday': 'Martes',
          'Wednesday': 'Miyerkules',
          'Thursday': 'Huwebes',
          'Friday': 'Biyernes',
          'Saturday': 'Sabado',
          'Sunday': 'Linggo',
        }[match[0]]!;
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
                // Date Container
                // Container(
                //   padding: EdgeInsets.all(screenWidth * 0.04),
                //   decoration: BoxDecoration(
                //     color: const Color.fromARGB(255, 138, 167, 136),
                //     borderRadius: BorderRadius.circular(12),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.1),
                //         blurRadius: 5,
                //         spreadRadius: 2,
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     // Changed from Column to Row for two-column layout

                //     children: [
                //       // Left Column
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             // Display WiFi status snackbar

                //           ],
                //         ),
                //       ),

                //       PlotSelection(),
                //     ],
                //   ),
                // ),
                // SizedBox(height: screenHeight * 0.02),
                SizedBox(height: screenHeight * 0.02),

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
                                isFilipino ? 'Halumigmig: ' : 'Humidity: ',
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
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    color: const Color.fromARGB(255, 247, 246, 237),
                    margin: EdgeInsets.all(screenWidth * 0.02),
                    height: screenHeight * 0.34, //0.237
                    width: double.infinity,
                    child: HelperMsg(
                      key: ValueKey(
                          selectedPlot), // Force rebuild on plot change
                      dataProvider: dataProvider!,
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
