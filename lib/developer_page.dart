import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
 final List<Map<String, dynamic>> developers = [
  {
    'name': 'Joanna Marie Caguco',
    'role': 'Developer',
    'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
    'image': 'assets/jm.png',
    'position': {'top': -10.0, 'left': 45.0, 'width': 100.0, 'height': 150.0},
    'namePosition': {'left': 140.0, 'top': 10.0},
    'rolePosition': {'left': 145.0, 'top': 40.0},
  },
  {
    'name': 'Edhel John Tubal',
    'role': 'Developer',
    'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
    'image': 'assets/edhel.png',
    'position': {'top': -5.0, 'left': 300.0, 'width': 90.0, 'height': 145.0},
    'namePosition': {'left': 130.0, 'top': 15.0},
    'rolePosition': {'left': 135.0, 'top': 45.0},
  },
  {
    'name': 'Jenny Lyn Vallador',
    'role': 'Tambay',
    'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
    'image': 'assets/jenny.png',
    'position': {'top': -10.0, 'left': 1.0, 'width': 160.0, 'height': 150.0},
    'namePosition': {'left': 170.0, 'top': 20.0},
    'rolePosition': {'left': 175.0, 'top': 50.0},
  },
  {
    'name': 'Marvin Vidallo',
    'role': 'Project Manager',
    'description': 'Lorem ipsum dolor sit amet. Et modi suscipit a enim optio.',
    'image': 'assets/marvin.png',
    'position': {'top': -38.0, 'left': 17.0, 'width': 120.0, 'height': 175.0},
    'namePosition': {'left': 160.0, 'top': 12.0},
    'rolePosition': {'left': 165.0, 'top': 42.0},
  },
];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Developers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 125, 171, 124),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 125, 171, 124),
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0), 
        child: ListView.builder(
          itemCount: developers.length,
          itemBuilder: (context, index) {
            final developer = developers[index];
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 120),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        developer['name']!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,  color: Color.fromARGB(255, 31, 45, 31),),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        developer['role']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal,),
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
            );
          },
        ),
      ),
    );
  }
}
