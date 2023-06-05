import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(); // Load the environment variables

  runApp(MyApp());
}


class EmployeeData {
  final int empID;
  final String fname;
  final String lname;
  final bool isManager;
  final String department;
  final String email;
  final String password;

  const EmployeeData({
    required this.empID,
    required this.fname,
    required this.lname,
    required this.isManager,
    required this.department,
    required this.email,
    required this.password
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showCounter = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleCounterVisibility() {
    setState(() {
      _showCounter = !_showCounter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_showCounter) ...[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleCounterVisibility,
              child: Text(_showCounter ? 'Hide Counter' : 'Show Counter'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
