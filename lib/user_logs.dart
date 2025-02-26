import 'package:flutter/material.dart';

class AddLogPage extends StatefulWidget {
  @override
  _AddLogPageState createState() => _AddLogPageState();
}

class _AddLogPageState extends State<AddLogPage> {
  final _formKey = GlobalKey<FormState>();
  final _logController = TextEditingController();

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _submitLog() {
    if (_formKey.currentState!.validate()) {
      // Handle log submission
      String log = _logController.text;
      print('Log submitted: $log');
      // Clear the text field
      _logController.clear();
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Log submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User Log'),
        backgroundColor: const Color.fromARGB(255, 100, 122, 99),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _logController,
                decoration: InputDecoration(
                  labelText: 'Enter your log',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a log';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitLog,
                child: Text('Submit Log'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 100, 122, 99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
