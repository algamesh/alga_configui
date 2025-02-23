import 'package:flutter/material.dart';
import 'package:alga_configuikit/src/second_page.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Config UI Example >>>>>>>>>>>>>>>',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  void _goToConfigPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecondPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Draggable Grid'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.blue),
              onPressed: () => _goToConfigPage(context),
            ),
          ),
        ],
      ),
    );
  }
}
