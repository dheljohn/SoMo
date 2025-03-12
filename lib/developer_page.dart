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
      'name': 'Joanna Caguco',
      'role': 'Full Stack Developer',
      'image': 'assets/jm.png',
      'position': {'top': 9.0, 'left': 70.0, 'width': 100.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/named-JM',
        'facebook': 'https://www.facebook.com/JM.cags/',
        'linkedin': 'https://linkedin.com/in/joannamarie',
      }
    },
    {
      'name': 'Edhel Tubal',
      'role': 'Mobile App Developer',
      'image': 'assets/edhel.png',
      'position': {'top': 8.0, 'left': 60.0, 'width': 120.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/dheljohn',
        'facebook': 'https://www.facebook.com/edhel.johnn',
        'linkedin': 'https://linkedin.com/in/edheljohn',
      }
    },
    {
      'name': 'Jenny Vallador',
      'role': 'Frontend Developer',
      'image': 'assets/jenny.png',
      'position': {'top': 10.0, 'left': 40.0, 'width': 160.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/ImJennyLynn',
        'facebook': 'https://www.facebook.com/jennylyn.vallador',
        'linkedin': 'https://linkedin.com/in/jennylyn',
      }
    },
    {
      'name': 'Marvin Vidallo',
      'role': 'Tech Support',
      'image': 'assets/marvin.png',
      'position': {'top': 9.0, 'left': 60.0, 'width': 115.0, 'height': 140.0},
      'links': {
        'github': 'https://github.com/marvin',
        'facebook': 'https://www.facebook.com/jonmarvinvidallo',
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
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 249, 247),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0),
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
                    Container(
                      width: screenWidth * 1.5,
                      height: 110, //100 default
                      margin:
                          const EdgeInsets.fromLTRB(46, 40, 46, 0), //20 default
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 242, 239, 231),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromARGB(255, 42, 83, 39),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 140),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: screenWidth * 0.014),
                              Text(
                                developer['name']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 31, 45, 31),
                                ),
                              ),
                              Text(
                                developer['role']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.028,
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
                                      width: screenWidth * 0.07,
                                      height: screenWidth * 0.07,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _launchURL(
                                        developer['links']['facebook']),
                                    child: Image.asset(
                                      'assets/fb.png',
                                      width: screenWidth * 0.07,
                                      height: screenWidth * 0.07,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _launchURL(
                                        developer['links']['linkedin']),
                                    child: Image.asset(
                                      'assets/linked.png',
                                      width: screenWidth * 0.07,
                                      height: screenWidth * 0.07,
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
