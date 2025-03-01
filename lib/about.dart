import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/developer_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48), // Reduced height
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 100, 122, 99),
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Color.fromARGB(200, 255, 255, 255),
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "About"),
                Tab(text: "Developers"),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            // First Tab (About)
            AboutTab(),

            // Second Tab (Calla - Placeholder)
            DeveloperPage(),
          ],
        ),
      ),
    );
  }
}

// About Tab Content
class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Image Placeholder
            Center(
              child: Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Placeholder background color
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 42, 83, 39),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Image of Prototype',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // About Section
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 242, 239, 231),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromARGB(255, 42, 83, 39),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ],
        ),
      ),
    );
  }
}
