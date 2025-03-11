import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/developer_page.dart';
import 'package:soil_monitoring_app/soilmoistures_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 100, 122, 99),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'About',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Color.fromARGB(200, 255, 255, 255),
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Soil Moisture \n     Levels"),
                Tab(text: "Application"),
                Tab(text: "Developers"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SoilMoistureInfo(),
            const AboutTab(),
            const DeveloperPage(),
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
    return Container(
      color: const Color.fromARGB(255, 242, 239, 231),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // App Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/app.jpg',
                    width: 250,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // About Section
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 42, 83, 39),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(15),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      'SOMO (Soil Moisture Monitoring) is an application designed to help you keep track of soil moisture conditions in real-time. Whether you are a farmer, gardener, or plant enthusiast, SOMO provides data on soil moisture, temperature, and humidity, ensuring your plants get the right amount of water they need to thrive.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Key Features Section
              const Text(
                "Key Features",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 42, 83, 39),
                ),
              ),
              const SizedBox(height: 10),

              // Features List
              const FeatureItem(
                title: "📊 Dashboard",
                description:
                    "Monitor real-time soil moisture levels, temperature, and humidity all in one place.",
              ),
              const FeatureItem(
                title: "💬 Helper Message",
                description:
                    "Receive guidance and tips on maintaining optimal soil conditions for plant growth.",
              ),
              const FeatureItem(
                title: "🔍 Recommendations",
                description:
                    "Get watering suggestions based on soil moisture data and weather conditions.",
              ),
              const FeatureItem(
                title: "🔔 Notifications",
                description:
                    "Stay updated with alerts when soil conditions require attention.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Item Widget
class FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const FeatureItem(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
