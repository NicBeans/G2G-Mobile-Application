import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mysql1/mysql1.dart';

import 'package:flutter/widgets.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  //await dotenv.load(); // Load the environment variables
  runApp(MyApp());
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

  Future<void> connect(BuildContext ctx) async {
    print('about to exec');
    debugPrint("Connecting...");
    try {
      print('execing');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("LOADING"),
            content: CircularProgressIndicator(),
          );
        },
      );
      final conn = await MySqlConnection.connect(ConnectionSettings(
          host: 'db-mysql-fra1-itmda-do-user-14181038-0.b.db.ondigitalocean.com',
          port: 25060,
          user: 'doadmin',
          db: 'g2gsystemdata',
          password: 'AVNS_x9MsCEPSYvujay1CtiH'));
      debugPrint("Connected!");

      var result = await conn.query(
          'INSERT INTO EMPLOYEE (empID, f_name, l_name, isManager, department, email, password) values (1041, \'Emma1234\', \'Walker1\', 1, \'Marketing1\', \'em1ma.walker@example.com\', \'passw1ord10\')'
      );
      print('Inserted row id=${result.insertId}');
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> delete(BuildContext ctx) async {
    print('about to exec');
    debugPrint("Connecting...");
    try {
      print('execing');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("LOADING"),
            content: CircularProgressIndicator(),
          );
        },
      );
      final conn = await MySqlConnection.connect(ConnectionSettings(
          host: 'db-mysql-fra1-itmda-do-user-14181038-0.b.db.ondigitalocean.com',
          port: 25060,
          user: 'doadmin',
          db: 'g2gsystemdata',
          password: 'AVNS_x9MsCEPSYvujay1CtiH'));
      debugPrint("Connected!");

      var result = await conn.query(
          'DELETE FROM EMPLOYEE WHERE empID = 1041'
      );
      print('Deleted row id=${result.insertId}');
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> read(BuildContext ctx) async {
    print('about to exec');
    debugPrint("Connecting...");
    try {
      print('execing');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("LOADING"),
            content: CircularProgressIndicator(),
          );
        },
      );
      final conn = await MySqlConnection.connect(ConnectionSettings(
          host: 'db-mysql-fra1-itmda-do-user-14181038-0.b.db.ondigitalocean.com',
          port: 25060,
          user: 'doadmin',
          db: 'g2gsystemdata',
          password: 'AVNS_x9MsCEPSYvujay1CtiH'));
      debugPrint("Connected!");

      var result = await conn.query(
          'SELECT FROM EMPLOYEE WHERE empID = 1041'
      );
      print('Selected row id=${result.insertId}');
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }



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
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       if (_showCounter) ...[
      //         const Text(
      //           'You have pushed the button this many times:',
      //         ),
      //         Text(
      //           '$_counter',
      //           style: Theme.of(context).textTheme.titleLarge,
      //         ),
      //       ],
      //       const SizedBox(height: 20),
      //       ElevatedButton(
      //         onPressed: _toggleCounterVisibility,
      //         child: Text(_showCounter ? 'Hide Counter' : 'Show Counter'),
      //       ),
      //
      //     ],
      //   ),
      // ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                ElevatedButton(
                  onPressed: () => connect(context),
                  child: const Text("Connect")),
                ElevatedButton(
                  onPressed: () => delete(context),
                  child: const Text("Delete")),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    ])
        )
    );
  }
}
