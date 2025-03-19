import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:soil_monitoring_app/about.dart';
import 'package:soil_monitoring_app/dashB.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/historySection.dart';
import 'package:soil_monitoring_app/navBar.dart';
import 'package:soil_monitoring_app/tutorial.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showOverlay = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AppBar appBar = AppBar(
    backgroundColor: const Color.fromARGB(255, 100, 122, 99),
    iconTheme: const IconThemeData(
      color: Color.fromARGB(255, 42, 83, 39),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
        ),
      ],
    ),
  );

  int _currentIndex = 0;
  double humidity_v = 0.0;
  double temperature_v = 0.0;
  double moisture_a = 0.0;
  double moisture_s1 = 0.0;
  double moisture_s2 = 0.0;
  double moisture_s3 = 0.0;
  double moisture_s4 = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchDataFromFirebase();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'soil_monitoring_channel',
      'Soil Monitoring Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_sound'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Soil Moisture Alert',
      message,
      platformChannelSpecifics,
    );
  }

  void _fetchDataFromFirebase() {
    DatabaseReference humidityRef =
        FirebaseDatabase.instance.ref().child('Humidity/humidity');
    DatabaseReference temperatureRef =
        FirebaseDatabase.instance.ref().child('Temperature/temperature');
    DatabaseReference moistureAvgRef =
        FirebaseDatabase.instance.ref().child('Moisture/Average');
    DatabaseReference moistureDataRef =
        FirebaseDatabase.instance.ref().child('Moisture');

    // Fetch Humidity
    humidityRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() {
        humidity_v = value;
      });
    });

    // Fetch Temperature
    temperatureRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() {
        temperature_v = value;
      });
    });

    // Fetch Moisture Average
    moistureAvgRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() {
        moisture_a = value;
      });
    });

    // Fetch Moisture Data
    moistureDataRef.once().then((event) {
      final value = event.snapshot.value as Map?;
      if (value != null) {
        double moisture1 =
            double.tryParse(value['MoistureReadings_1']?.toString() ?? '') ??
                0.0;
        double moisture2 =
            double.tryParse(value['MoistureReadings_2']?.toString() ?? '') ??
                0.0;
        double moisture3 =
            double.tryParse(value['MoistureReadings_3']?.toString() ?? '') ??
                0.0;
        double moisture4 =
            double.tryParse(value['MoistureReadings_4']?.toString() ?? '') ??
                0.0;

        setState(() {
          moisture_s1 = moisture1;
          moisture_s2 = moisture2;
          moisture_s3 = moisture3;
          moisture_s4 = moisture4;
        });
        if (moisture1 < 40 && moisture1 >= 15) {
          _showGroupedNotification(
              'Sensor 1 detected dry soil. Irrigation may be needed to prevent dehydration.');
        }
        if (moisture2 < 40 && moisture2 >= 15) {
          _showGroupedNotification('Sensor 2 detected dry soil.');
        }
        if (moisture3 < 40 && moisture3 >= 15) {
          _showGroupedNotification('Sensor 3 detected dry soil.');
        }
        if (moisture4 < 40 && moisture4 >= 15) {
          _showGroupedNotification('Sensor 4 detected dry soil.');
        }

        //not group. only individual this logic is for individual notification
        // so if you want to show individual notification then uncomment this code
        // but this just display the recent changes, so if the sensor are synced then it will show only one notification
        // Check individual sensor readings
        // if (moisture1 < 40 && moisture1 >= 15 ||
        //     moisture2 < 40 && moisture2 >= 15 ||
        //     moisture3 < 40 && moisture3 >= 15 ||
        //     moisture4 < 40 && moisture4 >= 15) {
        //   if (moisture1 < 40 && moisture1 >= 15) {
        //     _showNotification('Sensor 1 detected dry soil.');
        //   }
        //   if (moisture2 < 40 && moisture2 >= 15) {
        //     _showNotification('Sensor 2 detected dry soil.');
        //   }
        //   if (moisture3 < 40 && moisture3 >= 15) {
        //     _showNotification('Sensor 3 detected dry soil.');
        //   }
        //   if (moisture4 < 40 && moisture4 >= 15) {
        //     _showNotification('Sensor 4 detected dry soil.');
        //   }
        //   // _showNotification('One of the sensors detected dry soil.');
        // }
        // **Grouped Notifications for Wet Soil**
        if (moisture1 > 75) {
          _showGroupedNotification(
              'Sensor 1 detected wet soil. Stop Iriggation to prevent overwatering.');
        }
        if (moisture2 > 75) {
          _showGroupedNotification('Sensor 2 detected wet soil.');
        }
        if (moisture3 > 75) {
          _showGroupedNotification('Sensor 3 detected wet soil.');
        }
        if (moisture4 > 75) {
          _showGroupedNotification('Sensor 4 detected wet soil.');
        }
      }
    });
  }

  Future<void> _showGroupedNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'soil_monitoring_channel',
      'Soil Monitoring Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_sound'),
      groupKey: 'soil_alerts_group', // Group Key for multiple notifications
      setAsGroupSummary: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await flutterLocalNotificationsPlugin.show(
      uniqueId, // Unique ID per notification
      'Soil Moisture Alert',
      message,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // Adjust breakpoint as needed
    return DataProvider(
      humidityValue: humidity_v,
      temperatureValue: temperature_v,
      moistureA: moisture_a,
      moistureS1: moisture_s1,
      moistureS2: moisture_s2,
      moistureS3: moisture_s3,
      moistureS4: moisture_s4,
      child: SafeArea(
        child: Scaffold(
          appBar: appBar,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  DashB(),
                  TutorialScreen(),
                  HistoryDisplay(),
                  AboutPage(),
                ],
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: const Color.fromARGB(255, 247, 246, 237),
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              margin: const EdgeInsets.fromLTRB(13, 0, 13, 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 100, 122, 99),
                border: Border.all(
                  color: Color.fromARGB(255, 42, 83, 39),
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors
                      .transparent, // Keeps it transparent to show Container color
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                  unselectedItemColor: Colors.white70,
                  showSelectedLabels: true,
                  selectedFontSize: screenWidth * 0.035,
                  showUnselectedLabels: true,
                  unselectedFontSize: screenWidth * 0.03,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Tooltip(
                        message: 'Dashboard',
                        child: _buildIcon(Icons.dashboard, 0, _currentIndex),
                      ),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Tooltip(
                        message: 'Tutorial',
                        child: _buildIcon(Icons.help, 1, _currentIndex),
                      ),
                      label: 'Tutorial',
                    ),
                    BottomNavigationBarItem(
                      icon: Tooltip(
                        message: 'History',
                        child: _buildIcon(Icons.history, 2, _currentIndex),
                      ),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: Tooltip(
                        message: 'About',
                        child: _buildIcon(Icons.info, 3, _currentIndex),
                      ),
                      label: 'About',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData iconData, int index, int _currentIndex) {
    bool isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        shape: BoxShape.circle, // Circle shape
      ),
      child: Icon(
        iconData,
        color: isSelected
            ? const Color.fromARGB(255, 125, 171, 124)
            : Colors.white, // Icon color
      ),
    );
  }

  navBar() {
    return const Navbar();
  }
}
