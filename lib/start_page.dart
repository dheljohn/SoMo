import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  bool _showGif = false; // Initially hide GIF

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500), // Smooth transition time
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _controller.forward();

    // Start GIF animation AFTER the circle transition completes (2.5s delay)
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        _showGif = true; // Show GIF after circle animation
      });

      // Navigate to Home after GIF animation completes (6s)
      Future.delayed(const Duration(seconds: 6), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double screenSize = MediaQuery.of(context).size.width * 3;
          double circleSize = screenSize * _circleAnimation.value;

          return Stack(
            children: [
              Container(
                color: _circleAnimation.value >= 1.0
                    ? const Color.fromARGB(
                        255, 247, 246, 237) // Background turns white
                    : const Color.fromARGB(255, 100, 122, 99),
              ),
              Center(
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 247, 246, 237),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: _showGif // Only show GIF after the circle transition
                    ? Image.asset(
                        'assets/LOGO.gif',
                        width: 250,
                        height: 250,
                      )
                    : const SizedBox(), // Hide GIF initially
              ),
            ],
          );
        },
      ),
    );
  }
}
