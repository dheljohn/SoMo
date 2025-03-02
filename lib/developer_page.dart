import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({Key? key}) : super(key: key);

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> developers = [
    {
      'name': 'Joanna Marie',
      'role': 'Lead Developer/Mobile App Developer/\nHardware Developer/Document Support',
      'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/jm.png',
      'imageWidth': 200.0,
      'imageHeight': 200.0,
      'imageTop': 1.0,
      'links': {
        'github': 'https://github.com/joannamarie',
        'facebook': 'https://facebook.com/joannamarie',
        'linkedin': 'https://linkedin.com/in/joannamarie',
      }
    },
    {
      'name': 'Edhel John',
      'role': 'Mobile App Developer Support/Mobile Cloud',
      'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/edhel.png',
      'imageWidth': 200.0,
      'imageHeight': 200.0,
      'imageTop': 1.0,
      'links': {
        'github': 'https://github.com/edheljohn',
        'facebook': 'https://facebook.com/edheljohn',
        'linkedin': 'https://linkedin.com/in/edheljohn',
      }
    },
    {
      'name': 'Jenny Lyn',
      'role': 'UI/UX Developer/Document/\nPrototype Designer',
      'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/jenny.png',
      'imageWidth': 200.0,
      'imageHeight': 200.0,
      'imageTop': 1.0,
      'links': {
        'github': 'https://github.com/jennylyn',
        'facebook': 'https://facebook.com/jennylyn',
        'linkedin': 'https://linkedin.com/in/jennylyn',
      }
    },
    {
      'name': 'Jon Marvin',
      'role': 'Document/Proof Reader',
      'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
      'image': 'assets/marvin.png',
      'imageWidth': 200.0,
      'imageHeight': 200.0,
      'imageTop': 1.0,
      'links': {
        'github': 'https://github.com/marvin',
        'facebook': 'https://facebook.com/marvin',
        'linkedin': 'https://linkedin.com/in/marvin',
      }
    },
  ];

  void _nextPage() {
    _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _previousPage() {
    _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 242, 239, 231),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: developers.length,
                 
                  itemBuilder: (context, index) {
                    final developer = developers[index];
                    return Center(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: 300,
                            height: 350,
                            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
                            padding: const EdgeInsets.only(top: 60, left: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color.fromARGB(255, 42, 83, 39),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 90),
                                Text(
                                  developer['name']!,
                                  style: const TextStyle(
                                    fontSize: 30,
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
                                const SizedBox(height: 30),
                                  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => launchUrl(Uri.parse(developer['links']['github'])),
                                  child: Image.asset('assets/github.png', width: 30, height: 30),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => launchUrl(Uri.parse(developer['links']['facebook'])),
                                  child: Image.asset('assets/fb.png', width: 30, height: 30),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => launchUrl(Uri.parse(developer['links']['linkedin'])),
                                  child: Image.asset('assets/linked.png', width: 30, height: 30),
                                ),
                              ],
                            ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: developer['imageTop'],
                            child: Image.asset(
                              developer['image']!,
                              width: developer['imageWidth'],
                              height: developer['imageHeight'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.black),
                    onPressed: _previousPage,
                  ),
                ),
                Positioned(
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 30, color: Colors.black),
                    onPressed: _nextPage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SmoothPageIndicator(
            controller: _pageController,
            count: developers.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Color.fromARGB(255, 42, 83, 39),
              dotColor: Color.fromARGB(255, 120, 122, 120),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
