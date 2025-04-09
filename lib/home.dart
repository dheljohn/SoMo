import 'dart:async';
import 'dart:math';

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
  Set<String> activeNotifications = {};
  // Inside _HomeState class in home.dart
  final Map<String, List<int>> moistureLevels = {
    'Lettuce': [60, 80],
    'Pechay': [50, 70],
    'Mustard': [40, 60],
  };

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
    _scheduleWaterReminders();
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

  void _fetchDataFromFirebase() async {
    // Fetch selected plot from Firebase
    DatabaseReference selectedPlotRef =
        FirebaseDatabase.instance.ref().child('SelectedPlot');
    DataSnapshot plotSnapshot = await selectedPlotRef.get();
    String selectedPlot =
        (plotSnapshot.value as Map?)?['plotName']?.toString() ?? 'Lettuce';

    // Get moisture range for selected crop
    List<int> idealRange = moistureLevels[selectedPlot] ?? [60, 80];
    int minMoisture = idealRange[0];
    int maxMoisture = idealRange[1];

    // Fetch Humidity
    DatabaseReference humidityRef =
        FirebaseDatabase.instance.ref().child('Humidity/humidity');
    humidityRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() => humidity_v = value);
      if (humidity_v < 41) {
        _showGroupedNotification(
            'Humidity is too low ($humidity_v%). Increase moisture levels.',
            'humidity_low');
      } else {
        activeNotifications.remove('humidity_low');
      }
      if (humidity_v > 69) {
        _showGroupedNotification(
            'Humidity is too high ($humidity_v%). Ventilation may be needed.',
            'humidity_high');
      } else {
        activeNotifications.remove('humidity_high');
      }
    });

    // Fetch Temperature
    DatabaseReference temperatureRef =
        FirebaseDatabase.instance.ref().child('Temperature/temperature');
    temperatureRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() => temperature_v = value);
      if (temperature_v < 18) {
        _showGroupedNotification(
            'Temperature is too low ($temperature_v°C). Protect crops from cold.',
            'temp_low');
      } else {
        activeNotifications.remove('temp_low');
      }
      if (temperature_v > 28 && temperature_v < 34) {
        _showGroupedNotification(
            'Temperature is hot at ($temperature_v°C). Heat stress risk for crops.',
            'temp_high');
      } else if (temperature_v > 34) {
        _showGroupedNotification(
            'Temperature is too hot ($temperature_v°C). Heat stress risk for crops.',
            'temp_high');
      } else {
        activeNotifications.remove('temp_high');
      }
    });

    // Fetch Moisture Average
    DatabaseReference moistureAvgRef =
        FirebaseDatabase.instance.ref().child('Moisture/Average');
    moistureAvgRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() => moisture_a = value);
    });

    // Fetch Moisture Data with dynamic thresholds
    DatabaseReference moistureDataRef =
        FirebaseDatabase.instance.ref().child('Moisture');
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

        // Helper function for moisture checks
        void checkMoisture(double value, String sensorNumber) {
          if (value < 8) return; // Sensor not deployed
          if (value <= 29) {
            _showGroupedNotification(
                'Sensor $sensorNumber detected Extremely Dry Soil. Irrigate immediately!',
                'moisture${sensorNumber}_low');
          } else if (value < minMoisture) {
            _showGroupedNotification(
                'Sensor $sensorNumber detected dry soil. Irrigation may be needed to prevent dehydration.',
                'moisture${sensorNumber}_low');
          } else if (value > maxMoisture) {
            _showGroupedNotification(
                'Sensor $sensorNumber detected wet soil. Stop Irrigation to prevent overwatering.',
                'moisture${sensorNumber}_high');
          } else {
            activeNotifications.remove('moisture${sensorNumber}_low');
            activeNotifications.remove('moisture${sensorNumber}_high');
          }
        }

        // Check all sensors
        checkMoisture(moisture_s1, '1');
        checkMoisture(moisture_s2, '2');
        checkMoisture(moisture_s3, '3');
        checkMoisture(moisture_s4, '4');
      }
    });
  }

  final List<String> morningGreetings = [
    "Magandang umaga! It's a fresh start—check your plants and give them a boost of water!",
    "Good morning! A little care goes a long way. Your plants are waiting for their morning sip!",
    "Rise and shine! Don't forget to water your greens and help them grow strong today.",
    "New day, new growth! Check your soil and give your plants the morning care they need.",
    "Good morning po! Baka kailangan na ng konting dilig ang mga halaman natin.",
  ];

  final List<String> middayReminders = [
    "☀️ Midday check! Mainit na, your plants might be thirsty.",
    "Time for a midday refresh! Check the soil and give a quick water boost if needed.",
    "Lunch break? Check your plants too, baka tuyô na sila.",
    "🌞 Don’t let the heat dry them out! Check your garden now.",
    "Midday alert! A little water now can keep your plants happy all afternoon.",
  ];

  final List<String> afternoonReminders = [
    "🌇 Before sunset, check your plants one last time today.",
    "Golden hour is a great time to water your plants!",
    "Don't forget to hydrate your greens before evening sets in.",
    "Last reminder of the day: Make sure your plants are comfy for the night.",
    "Before you rest, make sure your plants aren't thirsty!",
  ];

  void _scheduleWaterReminders() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final currentHour = now.hour;

      if ([8, 11, 15].contains(currentHour) && now.minute == 0) {
        String reminderMessage;
        final random = Random();

        switch (currentHour) {
          case 8:
            reminderMessage =
                morningGreetings[random.nextInt(morningGreetings.length)];
            break;
          case 11:
            reminderMessage =
                middayReminders[random.nextInt(middayReminders.length)];
            break;
          case 15:
            reminderMessage =
                afternoonReminders[random.nextInt(afternoonReminders.length)];
            break;
          default:
            reminderMessage = "Time to check your plants!";
        }

        _showReminderNotification(reminderMessage);
      }
    });
  }

  Future<void> _showReminderNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_channel',
      'Watering Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_sound'),
      groupKey: null,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await flutterLocalNotificationsPlugin.show(
      uniqueId,
      'Irrigation Reminder',
      message,
      platformDetails,
    );
  }

  Future<void> _showGroupedNotification(String message, String key) async {
    if (activeNotifications.contains(key)) {
      return; // Prevent duplicate notifications
    }

    activeNotifications.add(key); // Mark this notification as sent

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
