import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:soil_monitoring_app/global_switch.dart';

class SoilMoistureInfo extends StatelessWidget {
  List<Map<String, dynamic>> getMoistureLevels(bool isFilipino) {
    return [
      {
        'range': '15-29%',
        'color': const Color.fromARGB(255, 253, 133, 124),
        'description': isFilipino
            ? 'Matinding tuyong lupa!'
            : 'Extremely dry soil. Immediate watering required. Plants may wilt and suffer damage.',
      },
      {
        'range': '30-45%',
        'color': const Color.fromARGB(255, 236, 188, 66),
        'description': isFilipino
            ? 'Tuyong lupa / maayos ang drainage. Pag-isipang diligan sa lalong madaling panahon.'
            : 'Dry / well-drained soil. Consider watering soon. Some drought-tolerant plants can survive.',
      },
      {
        'range': '46-75%',
        'color': const Color.fromARGB(255, 103, 172, 105),
        'description': isFilipino
            ? 'Basang lupa. Perpektong kondisyon para sa karamihan ng mga halaman.'
            : 'Moist soil. Ideal condition for most plants. Ensures healthy growth.',
      },
      {
        'range': '76-90%',
        'color': const Color.fromARGB(255, 131, 174, 209),
        'description': isFilipino
            ? 'Napakabasang lupa. Iwasan ang sobrang pagdidilig upang maiwasan ang pagkabulok ng ugat.'
            : 'Wet soil. Avoid overwatering. Too much moisture can lead to root rot.',
      },
    ];
  }

  List<Map<String, dynamic>> getSoilTypes(bool isFilipino) {
    return [
      {
        'type': isFilipino ? 'Lupang Buhangin' : 'Sand Soil',
        'color': Colors.brown[300],
        'description': isFilipino
            ? 'Mabilis mag-drain at madaling matuyo. Kailangan ng madalas na pagdidilig.'
            : 'Drains water quickly and dries out faster. Requires frequent watering.',
      },
      {
        'type': isFilipino ? 'Lupang Loam' : 'Loam Soil',
        'color': Colors.brown[500],
        'description': isFilipino
            ? 'Pinakamainam para sa karamihan ng mga halaman. May balanseng moisture at drainage.'
            : 'Best for most plants. Retains moisture well while allowing good drainage.',
      },
      {
        'type': isFilipino ? 'Lupang Luwad' : 'Clay Soil',
        'color': Colors.brown[700],
        'description': isFilipino
            ? 'Matagal maghawak ng tubig. Mabagal mag-drain, kaya may panganib ng waterlogging.'
            : 'Holds water for long periods. Drains slowly, increasing the risk of waterlogging.',
      },
    ];
  }

  List<Map<String, dynamic>> humidtyLevels(bool isFilipino) {
    return [
      {
        'range': '0-40%',
        'color': const Color.fromARGB(255, 253, 133, 124),
        'description': isFilipino
            ? 'Masyadong tuyo. Maaaring magdulot ng pagkatuyo ng halaman.'
            : 'Too dry. Can cause plant dehydration.',
      },
      {
        'range': '40-70%',
        'color': const Color.fromARGB(255, 103, 172, 105),
        'description': isFilipino
            ? 'Katanggap-tanggap. Angkop para sa karamihan ng mga halaman.'
            : 'Accepted. Suitable for most plants.',
      },
      {
        'range': '70-100%',
        'color': const Color.fromARGB(255, 131, 174, 209),
        'description': isFilipino
            ? 'Masyadong mahalumigmig. May panganib ng fungal growth at sobrang pagdidilig.'
            : 'Too moist. Risk of fungal growth and overwatering.',
      },
    ];
  }

  List<Map<String, dynamic>> temperatureLevels(bool isFilipino) {
    return [
      {
        'range': '0°C - 18°C',
        'color': Colors.blue[300],
        'description': isFilipino
            ? 'Malamig. Panganib ng frost damage. Protektahan ang mga pananim gamit ang takip.'
            : 'Cold. Risk of frost damage. Protect crops with covers.',
      },
      {
        'range': '18°C - 23°C',
        'color': Colors.green[400],
        'description': isFilipino
            ? 'Komportable. Perpektong temperatura para sa karamihan ng mga pananim.'
            : 'Comfortable. Ideal temperature for most crops.',
      },
      {
        'range': '23°C - 29°C',
        'color': Colors.orange[300],
        'description': isFilipino
            ? 'Mainit. Magandang kundisyon ng paglago, ngunit bantayan ang moisture ng lupa.'
            : 'Warm. Good growth conditions, but monitor soil moisture.',
      },
      {
        'range': '29°C - 35°C',
        'color': Colors.red[300],
        'description': isFilipino
            ? 'Napakainit. Maaaring makaranas ng heat stress ang mga pananim. Siguraduhin ang tamang pagdidilig.'
            : 'Hot. Crops may experience heat stress. Ensure proper irrigation.',
      },
      {
        'range': 'Above 35°C',
        'color': Colors.red[700],
        'description': isFilipino
            ? 'Sobrang init. Mataas ang panganib ng pagkatuyo at pagkasira ng pananim. Magbigay ng lilim at tubig.'
            : 'Very hot. High risk of dehydration and crop damage. Provide shade and water.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isFilipino = context.watch<LanguageProvider>().isFilipino;
    final moistureLevels = getMoistureLevels(isFilipino);
    final soilTypes = getSoilTypes(isFilipino);
    final humidityLevels = humidtyLevels(isFilipino);
    final tempLevels = temperatureLevels(isFilipino);
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 247, 246, 237),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140.0,
              floating: true,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'lib/assets/images/image.png',
                  fit: BoxFit.contain,
                ),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const Text(
                      'Soil Moisture Levels',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 100, 122, 99)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final level = moistureLevels[index];
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 60,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: level['color'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  level['range'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  level['description'],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                  childCount: moistureLevels.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          'https://www.acurite.com/blogs/acurite-in-your-home/soil-moisture-guide-for-plants-and-vegetables#:~:text=It%20is%20important%20to%20note,between%2041%25%20%2D%2080%25.'));
                    },
                    child: const Text(
                      'Source: Soil Moisture Levels',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Relative Humidity Levels',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 100, 122, 99)),
                    ),
                    const SizedBox(height: 10),
                    ...humidityLevels.map((humidity) {
                      return _buildInfoCard(humidity['range'],
                          humidity['description'], humidity['color']);
                    }).toList(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          'https://www.researchgate.net/profile/Mostafa-Momin/publication/288835367/figure/fig1/AS:613906062012420@1523378019166/The-relative-humidity-versus-temperature-graph.png?fbclid=IwY2xjawJH1FlleHRuA2FlbQIxMAABHeTjbS7aH7FCdon-_qPC_e1I1SBoTK3gY4JWIf8f1ZnZXJ7phdMrmMaQqQ_aem_Tve0ayrku3PdjZDaBXRpfw'));
                    },
                    child: const Text(
                      'Source:Humidity levels',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const Text(
                      'Temperature Levels',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 100, 122, 99)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final level = tempLevels[index];
                    return _buildInfoCard(
                        level['range'], level['description'], level['color']);
                  },
                  childCount: tempLevels.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          'https://weatherspark.com/compare/y/134618~134516/Comparison-of-the-Average-Weather-in-Indang-and-Tanza'));
                    },
                    child: const Text(
                      'Source: Temperature Levels',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soil Types & Moisture Retention',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 100, 122, 99)),
                    ),
                    const SizedBox(height: 10),
                    ...soilTypes.map((soil) {
                      return _buildInfoCard(
                          soil['type'], soil['description'], soil['color']);
                    }).toList(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          'https://www.noble.org/regenerative-agriculture/soil/soil-and-water-relationships/#:~:text=Soils%20with%20smaller%20particles%20(silt,a%20higher%20water%2Dholding%20capacity.'));
                    },
                    child: const Text(
                      'Source: Soil Types & Moisture Retention',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, Color? color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 60,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
