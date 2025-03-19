import 'package:flutter/material.dart';

import 'package:soil_monitoring_app/developer_page.dart';
import 'package:soil_monitoring_app/soilmoistures_info.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/language_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFilipino = context.watch<LanguageProvider>().isFilipino;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), //to 60
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 100, 122, 99),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: const Color.fromARGB(200, 255, 255, 255),
              indicatorColor: Colors.white,
              tabs: [
                const Tab(text: "Soil Moisture \n     Levels"),
                Tab(text: isFilipino ? "Aplikasyon" : "Application"),
                Tab(text: isFilipino ? "Mga Gumawa" : "Developers"),
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
    bool isFilipino = context.watch<LanguageProvider>().isFilipino;

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

              Center(
                child: Text(
                  'SOMO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 42, 83, 39),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                isFilipino
                    ? 'Ang SOMO (Soil Moisture Monitoring) ay isang aplikasyon na tumutulong sa iyo na subaybayan ang kondisyon ng soil moisture ng real-time. Kung ikaw ay isang magsasaka, hardinero, o mahilig sa halaman, nagbibigay ang SOMO ng datos tungkol sa soil moisture, temperatura, at humidity, upang matiyak na nakakakuha ng tamang dami ng tubig ang iyong mga halaman upang lumago nang maayos.'
                    : 'SOMO (Soil Moisture Monitoring) is an application designed to help you keep track of soil moisture conditions in real-time. Whether you are a farmer, gardener, or plant enthusiast, SOMO provides data on soil moisture, temperature, and humidity, ensuring your plants get the right amount of water they need to thrive.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 20),

              // Key Features Section
              Text(
                isFilipino
                    ? "Pangunahing Katangian"
                    : "Key Features", // pa translate
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 42, 83, 39),
                ),
              ),
              const SizedBox(height: 10),

              // Features List
              FeatureItem(
                title: "📊 Dashboard",
                description: isFilipino
                    ? "Subaybayan ang real-time na soil moisture levels, temperatura, at humidity sa iisang lugar."
                    : "Monitor real-time soil moisture levels, temperature, and humidity all in one place.",
              ),
              FeatureItem(
                title: "💬 Helper Message",
                description: isFilipino
                    ? "Tumanggap ng babala at rekomendasyon sa pagdidilig batay sa antas ng soil moisture levels"
                    : "Receive a warning message and watering recommendation based on soil moisture levels. ",
              ),

              FeatureItem(
                title: "🔔 Notifications",
                description: isFilipino
                    ? "Manatiling updated sa mga alerto kapag nangangailangan ng atensyon ang kondisyon ng lupa."
                    : "Stay updated with alerts when soil conditions require attention.",
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
              color: Color.fromARGB(221, 44, 43, 43),
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
