import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({Key? key}) : super(key: key);

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> developers = [
    {
      'name': 'Joanna Marie',
      'role': 'Developer',
      'description':
          'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/jm.png',
      'position': {'top': -10.0, 'left': 70.0, 'width': 100.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/joannamarie',
        'facebook': 'https://facebook.com/joannamarie',
        'linkedin': 'https://linkedin.com/in/joannamarie',
      }
    },
    {
      'name': 'Edhel John ',
      'role': 'Developer',
      'description':
          'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/edhel.png',
      'position': {'top': -12.0, 'left': 60.0, 'width': 120.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/edheljohn',
        'facebook': 'https://facebook.com/edheljohn',
        'linkedin': 'https://linkedin.com/in/edheljohn',
      }
    },
    {
      'name': 'Jenny Lyn ',
      'role': 'Tambay',
      'description':
          'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/jenny.png',
      'position': {'top': -10.0, 'left': 40.0, 'width': 160.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/jennylyn',
        'facebook': 'https://facebook.com/jennylyn',
        'linkedin': 'https://linkedin.com/in/jennylyn',
      }
    },
    {
      'name': 'Marvin ',
      'role': 'Project Manager',
      'description':
          'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/marvin.png',
      'position': {'top': -12.0, 'left': 60.0, 'width': 115.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/marvin',
        'facebook': 'https://facebook.com/marvin',
        'linkedin': 'https://linkedin.com/in/marvin',
      }
    },
  ];

  List<bool> isVisible = [];

  @override
  void initState() {
    super.initState();
    isVisible = List<bool>.filled(developers.length, false);

    for (int i = 0; i < developers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          setState(() {
            isVisible[i] = true;
          });
        }
      });
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 249, 247),
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: ListView.builder(
          itemCount: developers.length,
          itemBuilder: (context, index) {
            final developer = developers[index];
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isVisible[index] ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                transform:
                    Matrix4.translationValues(0, isVisible[index] ? 0 : -50, 0),
                curve: Curves.easeOut,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const SizedBox(width: 40),
                    Container(
                      width: 350,
                      height: 110,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 46.0, vertical: 20.0),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 242, 239, 231),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color.fromARGB(255, 42, 83, 39),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 140),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 3),
                              Text(
                                developer['name']!,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 31, 45, 31),
                                ),
                              ),
                              Text(
                                developer['role']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 120, 122, 120),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _launchURL(
                                        developer['links']['github']),
                                    child: Image.asset(
                                      'assets/github.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _launchURL(
                                        developer['links']['facebook']),
                                    child: Image.asset(
                                      'assets/fb.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _launchURL(
                                        developer['links']['linkedin']),
                                    child: Image.asset(
                                      'assets/linked.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: developer['position']['top'],
                      left: developer['position']['left'],
                      child: Image.asset(
                        developer['image']!,
                        width: developer['position']['width'],
                        height: developer['position']['height'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
