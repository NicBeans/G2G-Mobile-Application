import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null, initialize it
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'g2g.db');

    // Delete the existing database file
    await deleteDatabase(path);

    // Create a new database instance
    final database = await openDatabase(path, version: 1, onCreate: _createDatabase);

    return database;
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE EMPLOYEE (
        empID INTEGER PRIMARY KEY,
        f_name TEXT,
        l_name TEXT,
        isManager INTEGER,
        department TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE OBSERVATIONS (
        obsID INTEGER PRIMARY KEY,
        empID INTEGER,
        timestamp TEXT,
        medal INTEGER,
        yellowCard INTEGER,
        hygiene INTEGER,
        reason TEXT,
        FOREIGN KEY (empID) REFERENCES EMPLOYEE(empID)
      )
    ''');

    // Insert template data
    await db.execute('''
      INSERT INTO EMPLOYEE (empID, f_name, l_name, isManager, department, email, password)
      VALUES
        (1, 'John', 'Doe', 0, 'Sales', 'john.doe@example.com', 'password1'),
        (2, 'Jane', 'Smith', 1, 'HR', 'jane.smith@example.com', 'password2'),
        (3, 'Michael', 'Johnson', 0, 'IT', 'michael.johnson@example.com', 'password3'),
        (4, 'Emily', 'Davis', 0, 'Finance', 'emily.davis@example.com', 'password4'),
        (5, 'Robert', 'Wilson', 0, 'Marketing', 'robert.wilson@example.com', 'password5'),
        (6, 'Sophia', 'Brown', 1, 'Operations', 'sophia.brown@example.com', 'password6'),
        (7, 'David', 'Anderson', 0, 'Sales', 'david.anderson@example.com', 'password7'),
        (8, 'Olivia', 'Taylor', 0, 'IT', 'olivia.taylor@example.com', 'password8'),
        (9, 'James', 'Clark', 0, 'Finance', 'james.clark@example.com', 'password9'),
        (10, 'Emma', 'Walker', 0, 'Marketing', 'emma.walker@example.com', 'password10')
    ''');

    await db.execute('''
      INSERT INTO OBSERVATIONS (obsID, empID, timestamp, medal, yellowCard, hygiene, reason)
      VALUES
        (1, 1, '2023-06-01 09:30:00', 2, 0, 4, 'Exceeded sales targets'),
        (2, 2, '2023-06-02 14:45:00', 1, 1, 2, 'Provided excellent customer service'),
        (3, 3, '2023-06-03 11:15:00', 0, 0, 3, 'Resolved IT issues promptly'),
        (4, 4, '2023-06-04 16:20:00', 1, 0, 1, 'Ensured accurate financial reporting'),
        (5, 5, '2023-06-05 13:00:00', 0, 2, 2, 'Implemented successful marketing campaign'),
        (6, 6, '2023-06-01 10:00:00', 3, 0, 5, 'Streamlined operations processes'),
        (7, 7, '2023-06-02 15:30:00', 1, 0, 1, 'Closed significant sales deal'),
        (8, 8, '2023-06-03 12:45:00', 0, 1, 3, 'Maintained IT security protocols'),
        (9, 9, '2023-06-04 17:10:00', 0, 0, 2, 'Analyzed financial data accurately'),
        (10, 10, '2023-06-05 14:15:00', 1, 1, 4, 'Developed effective marketing strategy')
    ''');
  }
}

class Employee {
  final int empID;
  final String firstName;
  final String lastName;
  final int isManager;
  final String department;
  final String email;
  final String password;

  Employee({
    required this.empID,
    required this.firstName,
    required this.lastName,
    required this.isManager,
    required this.department,
    required this.email,
    required this.password,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      empID: map['empID'],
      firstName: map['f_name'],
      lastName: map['l_name'],
      isManager: map['isManager'],
      department: map['department'],
      email: map['email'],
      password: map['password'],
    );
  }
}

class Observation {
  final int empID;
  final String timestamp;
  final int medal;
  final int yellowCard;
  final int hygiene;
  final String reason;

  Observation({
    required this.empID,
    required this.timestamp,
    required this.medal,
    required this.yellowCard,
    required this.hygiene,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'empID': empID,
      'timestamp': timestamp,
      'medal': medal,
      'yellowCard': yellowCard,
      'hygiene': hygiene,
      'reason': reason,
    };
  }
}

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

  Future<void> loginverification(BuildContext context) async {
    try {
      final db = await DatabaseHelper.database;
      final employees = await db.rawQuery('''
      SELECT * FROM EMPLOYEE WHERE email = ? AND password = ?
    ''', [emailController.text, passwordController.text]);

      if (employees.isNotEmpty) {
        // Authentication successful
        Navigator.pushNamed(context, '/home');
      } else {
        // Authentication failed
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Invalid credentials"),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey, // Set the header background color to gray
        title: Image.asset(
          'assets/logo.png',
          height: 40, // Adjust the height as needed
        ),
        centerTitle: true, // Center the logo horizontally
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.4,
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
                  fillColor: Colors.white, // Set the text field's fill color to white
                  filled: true,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  fillColor: Colors.white, // Set the text field's fill color to white
                  filled: true,
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
                  Spacer(), // Add spacer to push the Forgot Password button to the right
                  TextButton(
                    onPressed: () {
                      // Add your forgot password logic here
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Colors.blue, // Set the button text color to blue
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => loginverification(context),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button from the app bar
        title: Text('Good Morning, Temuso!', style: TextStyle(color: Colors.white)), // Set the text and color for the title
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Align content in the center vertically
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Make Observation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medal_submission');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Set the button color to green
                  padding: EdgeInsets.all(16.0), // Add padding to the button
                ),
                child: Text(
                  'Medals',
                  style: TextStyle(fontSize: 20), // Increase the font size
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/yellow_card');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow, // Set the button color to yellow
                  padding: EdgeInsets.all(16.0), // Add padding to the button
                ),
                child: Text(
                  'Yellow Card',
                  style: TextStyle(fontSize: 20), // Increase the font size
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/hygiene_submission');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Set the button color to red
                  padding: EdgeInsets.all(16.0), // Add padding to the button
                ),
                child: Text(
                  'Hygiene',
                  style: TextStyle(fontSize: 20), // Increase the font size
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => logout(context),
                      child: Text('Log Out'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/leaderboard');
                      },
                      child: Text('Leaderboard'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedalSubmissionPage extends StatefulWidget {
  @override
  _MedalSubmissionPageState createState() => _MedalSubmissionPageState();
}


class _MedalSubmissionPageState extends State<MedalSubmissionPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];

  int selectedEmployeeId = -1; // Default value indicating no employee is selected

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final db = await DatabaseHelper.database;
      final results = await db.rawQuery('SELECT * FROM EMPLOYEE WHERE isManager = 0');
      final List<Employee> fetchedEmployees =
      results.map((row) => Employee.fromMap(row)).toList();

      setState(() {
        employees = fetchedEmployees;
        filteredEmployees = fetchedEmployees;
      });
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
    }
  }

  void filterEmployees(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredEmployees = employees;
      } else {
        filteredEmployees = employees.where((employee) {
          final fullName = '${employee.firstName} ${employee.lastName}'.toLowerCase();
          return fullName.contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void selectEmployee(int employeeId) {
    setState(() {
      selectedEmployeeId = employeeId;
    });
  }

  Future<void> submitMedal() async {
    if (selectedEmployeeId == -1) {
      // No employee selected
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final reason = reasonController.text; // Get the reason from the text field

    final observation = Observation(
      empID: selectedEmployeeId,
      timestamp: timestamp,
      medal: 1, // Assuming a medal value of 1 for simplicity
      yellowCard: 0, // Assuming a default value of 0 for simplicity
      hygiene: 0, // Assuming a default value of 0 for simplicity
      reason: reason, // Replace with the actual reason value
    );

    try {
      final db = await DatabaseHelper.database;
      await db.insert('OBSERVATIONS', observation.toMap());
      print('Medal submitted successfully!');
      print(selectedEmployeeId);
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              Text(
                'Medal Submission',
                style: TextStyle(fontSize: 24, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: filterEmployees,
                  decoration: InputDecoration(
                    hintText: 'Find Employee',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Display filtered employees
              ListView.builder(
                shrinkWrap: true,
                itemCount: searchController.text.isEmpty ? 0 : filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployees[index];
                  return ListTile(
                    title: Text('${employee.firstName} ${employee.lastName}'),
                    subtitle: Text(employee.department),
                    onTap: () {
                      selectEmployee(employee.empID);
                      print('Selected Employee: ${employee.firstName} ${employee.empID}');
                    },
                  );
                },
              ),

              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                height: 120.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Reason for Submission',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: submitMedal,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              Text(
                'Yellow Card Submission',
                style: TextStyle(fontSize: 24, color: Colors.orangeAccent),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find Employee',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Yellow Card',
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: '1',
                          child: Text('1'),
                        ),
                        DropdownMenuItem<String>(
                          value: '2',
                          child: Text('2'),
                        ),
                        DropdownMenuItem<String>(
                          value: '3',
                          child: Text('3'),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Text('Points:', style: TextStyle(color: Colors.black)),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                height: 120.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Reason for Submission',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HygieneSubmissionPage extends StatefulWidget {
  @override
  _HygieneSubmissionPageState createState() => _HygieneSubmissionPageState();
}

class _HygieneSubmissionPageState extends State<HygieneSubmissionPage> {
  String selectedButton = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              Text(
                'Hygiene Submission',
                style: TextStyle(fontSize: 24, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find Employee',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Hygiene Category',
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: '1',
                          child: Text('1'),
                        ),
                        DropdownMenuItem<String>(
                          value: '2',
                          child: Text('2'),
                        ),
                        DropdownMenuItem<String>(
                          value: '3',
                          child: Text('3'),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Text('Points:', style: TextStyle(color: Colors.black)),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'POOR';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == 'POOR'
                          ? Colors.redAccent
                          : Colors.transparent,
                    ),
                    child: Text('POOR'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'STANDARD';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == 'STANDARD'
                          ? Colors.orangeAccent
                          : Colors.transparent,
                    ),
                    child: Text('STANDARD'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'EXCELLENT';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == 'EXCELLENT'
                          ? Colors.green
                          : Colors.transparent,
                    ),
                    child: Text('EXCELLENT'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                height: 120.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Reason for Submission',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              SizedBox(height: 16.0),
          Text(
            'June 2023 Leader Board',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ObservationLogPage()),
                  );
                },
                child: Text('Observation Log'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Rank',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Score',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('John Doe'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('1'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('100'),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Jane Smith'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('2'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('90'),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Alex Johnson'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('3'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('85'),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Sarah Brown'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('4'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('80'),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Michael Wilson'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('5'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('75'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ObservationLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              Text(
                'Observation Log',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Employee',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Manager',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '2023-06-01',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'John Doe',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Jane Smith',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'M',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '2023-06-02',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Jane Smith',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'John Doe',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Y/C',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Additional table rows...
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}