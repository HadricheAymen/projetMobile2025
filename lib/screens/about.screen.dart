import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trivia Quiz App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('This app uses the OpenTDB API to fetch trivia questions.'),
            Text('Version: 1.0.0'),
            Text('Developed by: Hadriche Aymen And Mohamed Kamoun'),
          ],
        ),
      ),
    );
  }
}
