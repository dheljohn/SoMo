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

  @override
  Widget build(BuildContext context) {
    bool isFilipino = context.watch<LanguageProvider>().isFilipino;
    final moistureLevels = getMoistureLevels(isFilipino);
    final soilTypes = getSoilTypes(isFilipino);

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
                delegate: SliverChildListDelegate([
                  const Text(
                    'Soil Moisture Levels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 122, 99),
                    ),
                  ),
                ]),
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
                      ],
                    );
                  },
                  childCount: moistureLevels.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: soilTypes.map((soil) {
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
                            child: Text(
                              soil['description'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
