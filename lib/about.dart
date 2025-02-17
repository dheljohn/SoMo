import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 125, 171, 124),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png', //  palitan ng image ng prototype kapag meron na
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),

              // About Section
              Container(
                decoration: BoxDecoration(
                   color: Color.fromARGB(255, 242, 239, 231),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                        color: Color.fromARGB(255, 42, 83, 39),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SOMO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 125, 171, 124),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'SOMO (Soil Monitoring) is an innovative application designed to help you keep track of soil conditions in real-time. Whether you are a farmer, gardener, or simply a plant enthusiast, SOMO provides accurate data on soil moisture, temperature, and humidity, ensuring your plants get the right amount of water and nutrients they need to thrive.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Key Features Section
              // Container(
              //   decoration: BoxDecoration(
              //      color: Color.fromARGB(255, 242, 239, 231),
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(
              //           color: Color.fromARGB(255, 42, 83, 39),
              //       width: 2,
              //     ),
              //   ),
              //   padding: const EdgeInsets.all(15),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: const [
              //       Text(
              //         'Key Features:',
              //         style: TextStyle(
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //           color: Color.fromARGB(255, 125, 171, 124),
              //         ),
              //       ),
              //       SizedBox(height: 10),
              //       Text(
              //         '- Real-time soil moisture monitoring\n'
              //         '- Temperature and humidity tracking\n'
              //         '- Notifications for dry or overwatered soil\n'
              //         '- Historical data and trend analysis\n'
              //         '- User-friendly interface with easy navigation',
              //         style: TextStyle(fontSize: 16, color: Colors.black87),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

            
            ],
          ),
        ),
      ),
    );
  }
}
