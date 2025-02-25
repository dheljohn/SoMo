import 'package:flutter/material.dart';

class PlotSelectionPage extends StatefulWidget {
  const PlotSelectionPage({super.key});

  @override
  State<PlotSelectionPage> createState() => _PlotSelectionPageState();
}

class _PlotSelectionPageState extends State<PlotSelectionPage> {
  final List<String> _plots = ['Plot A', 'Plot B', 'Plot C', 'Plot D'];
  String? _selectedPlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Plot Area'),
        backgroundColor: const Color.fromARGB(255, 42, 83, 39),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose a plot to monitor:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPlot,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text('Select a Plot'),
              items: _plots.map((plot) {
                return DropdownMenuItem(
                  value: plot,
                  child: Text(plot),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlot = value;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedPlot == null
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected Plot: $_selectedPlot'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 42, 83, 39),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Confirm Selection',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
