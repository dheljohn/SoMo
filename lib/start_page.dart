import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Navigate to Home after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
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
              // Expanding white circle that eventually covers the screen
              Container(
                color: _circleAnimation.value >= 1.0 
                    ? const Color.fromARGB(255, 247, 246, 237) // Circle color takes over
                    : const Color.fromARGB(255, 100, 122, 99), // Initial background color
              ),

              Center(
                child: ClipOval(
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 247, 246, 237), // Circle color
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Logo fades in and stays on the last GIF frame
              Center(
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: Image.asset(
                    'assets/LOGO.gif',
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
