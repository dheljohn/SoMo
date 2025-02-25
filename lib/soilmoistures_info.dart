import 'package:flutter/material.dart';

class SoilMoistureInfo extends StatelessWidget {
  final List<Map<String, dynamic>> moistureLevels = [
    {
      'range': '15-30%',
      'color': const Color.fromARGB(255, 253, 133, 124),
      'description': 'Extremely dry soil. Immediate watering required. Plants may wilt and suffer damage.',
      'recommendation': 'Water immediately. Check moisture again in 6-12 hours.'
    },
    {
      'range': '30-45%',
      'color': const Color.fromARGB(255, 236, 188, 66),
      'description': 'Dry / well-drained soil. Consider watering soon. Some drought-tolerant plants can survive.',
      'recommendation': 'Water within the next 12-24 hours. Monitor plant condition.'
    },
    {
      'range': '45-75%',
      'color': const Color.fromARGB(255, 103, 172, 105),
      'description': 'Moist soil. Ideal condition for most plants. Ensures healthy growth.',
      'recommendation': 'No immediate watering needed. Check moisture again in 1-2 days.'
    },
    {
      'range': '75-90%',
      'color': const Color.fromARGB(255, 131, 174, 209),
      'description': 'Wet soil. Avoid overwatering. Too much moisture can lead to root rot.',
      'recommendation': 'Do not water. Check moisture levels again in 2-3 days.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'lib/assets/images/image.png',
                fit: BoxFit.contain,
              ),
              title: const Text(
                'Soil Moisture Levels',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              centerTitle: true,
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
                          color: Colors.white, // Set the background of the whole container to white
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
                            // Percentage Column with Background Color
                            Container(
                              width: 80,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: level['color'], // Only this column has a background color
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                level['range'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Description Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['description'],
                                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Recommendation: ${level['recommendation']}',
                                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
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
        ],
      ),
    );
  }
}
