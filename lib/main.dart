import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  //await dotenv.load(); // Load the environment variables
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Observation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/medal_submission': (context) => MedalSubmissionPage(),
        '/yellow_card': (context) => YellowCardPage(),
        '/hygiene_submission': (context) => HygieneSubmissionPage(),
        '/leaderboard': (context) => LeaderboardPage(),
        '/observation_log': (context) => ObservationLogPage(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> rememberMe = ValueNotifier<bool>(false);

  void login(BuildContext context) {
    // Perform login authentication logic here
    // You can check the email and password entered by the user
    // and navigate to the home page if the authentication is successful
    Navigator.pushNamed(context, '/home');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey, // Set the header background color to gray
        title: Image.asset(
          'assets/logo.png', // Replace 'assets/logo.png' with the path to your logo image
          height: 40, // Adjust the height as needed
        ),
        centerTitle: true, // Center the logo horizontally
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Container(
          width: 300, // Set the width of the container to make it smaller
          height: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.lightBlue[100], // Set the background color of the container to light blue
            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: rememberMe,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (newValue) {
                          rememberMe.value = newValue!;
                        },
                      );
                    },
                  ),
                  Text('Remember me'),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => login(context),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  void logout(BuildContext context) {
    // Perform logout logic here
    Navigator.pushNamed(context, '/login');
  }

  Future<void> connect(BuildContext context) async {
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

  Future<void> delete(BuildContext context) async {
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

  Future<void> read(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medal_submission');
              },
              child: Text('Medal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/yellow_card');
              },
              child: Text('Yellow Card'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/hygiene_submission');
              },
              child: Text('Hygiene'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/leaderboard');
              },
              child: Text('Leaderboard'),
            ),
            ElevatedButton(
              onPressed: () => logout(context),
              child: Text('Log Out'),
            ),
            ElevatedButton(
                onPressed: () => connect(context),
                child: const Text("Connect")),
            ElevatedButton(
                onPressed: () => delete(context),
                child: const Text("Delete")),
          ],
        ),
      ),
    );
  }
}

class MedalSubmissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medal Submission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee dropdown (multi-select)
            // Medal dropdown
            // Points label
            // Reason text field
            // Submit button
          ],
        ),
      ),
    );
  }
}

class YellowCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yellow Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee dropdown (multi-select)
            // Yellow Card dropdown
            // Points label
            // Reason text field
            // Submit button
          ],
        ),
      ),
    );
  }
}

class HygieneSubmissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hygiene Submission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee dropdown (multi-select)
            // Hygiene dropdown
            // Points label
            // Completion dropdown (poorly, standard, excellent)
            // Reason text field
            // Submit button
          ],
        ),
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/observation_log');
              },
              child: Text('Observation Log'),
            ),
            // Leaderboard table
          ],
        ),
      ),
    );
  }
}

class ObservationLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Observation Log'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Observation log table
          ],
        ),
      ),
    );
  }
}
