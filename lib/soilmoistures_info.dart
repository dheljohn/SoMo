import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class SoilMoistureInfo extends StatelessWidget {
  final List<Map<String, dynamic>> moistureLevels = [
    {
      'range': '15-29%',
      'color': const Color.fromARGB(255, 253, 133, 124),
      'description':
          'Extremely dry soil. Immediate watering required. Plants may wilt and suffer damage.',
    },
    {
      'range': '30-45%',
      'color': const Color.fromARGB(255, 236, 188, 66),
      'description':
          'Dry / well-drained soil. Consider watering soon. Some drought-tolerant plants can survive.',
    },
    {
      'range': '46-75%',
      'color': const Color.fromARGB(255, 103, 172, 105),
      'description':
          'Moist soil. Ideal condition for most plants. Ensures healthy growth.',
    },
    {
      'range': '76-90%',
      'color': const Color.fromARGB(255, 131, 174, 209),
      'description':
          'Wet soil. Avoid overwatering. Too much moisture can lead to root rot.',
    },
  ];

  final List<Map<String, dynamic>> soilTypes = [
    {
      'type': 'Sand Soil',
      'color': Colors.brown[300],
      'description':
          'Drains water quickly and dries out faster. Requires frequent watering.',
    },
    {
      'type': 'Loam Soil',
      'color': Colors.brown[500],
      'description':
          'Best for most plants. Retains moisture well while allowing good drainage.',
    },
    {
      'type': 'Clay Soil',
      'color': Colors.brown[700],
      'description':
          'Holds water for long periods. Drains slowly, increasing the risk of waterlogging.',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                          color: const Color.fromARGB(255, 100, 122, 99)),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level['description'],
                                      style: const TextStyle(
                                          color: Colors.black87, fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
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
                          color: const Color.fromARGB(255, 100, 122, 99)),
                    ),
                    const SizedBox(height: 10),
                    ...soilTypes.map((soil) {
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
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: soil['color'],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    soil['type'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    soil['description'],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
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
          launchUrl(Uri.parse('https://www.acurite.com/blogs/acurite-in-your-home/soil-moisture-guide-for-plants-and-vegetables#:~:text=It%20is%20important%20to%20note,between%2041%25%20%2D%2080%25.')); // Replace with actual link
        },
        child: const Text(
          'Source: Soil Moisture Information',
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
  
}