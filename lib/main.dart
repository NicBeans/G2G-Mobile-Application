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

  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      empID: map['empID'],
      timestamp: map['timestamp'],
      medal: map['medal'],
      yellowCard: map['yellowCard'],
      hygiene: map['hygiene'],
      reason: map['reason'],
    );
  }

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
  Future<List<Observation>> getObservationsFromDatabase() async {
    final database = await DatabaseHelper.database;

    final observationData = await database.query('OBSERVATIONS');

    final observations = observationData.map((data) => Observation.fromMap(data)).toList();

    return observations;
  }
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
    '/observation_log': (context) => FutureBuilder<List<Observation>>(
    future: getObservationsFromDatabase(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator();
    } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
    } else {
    final observations = snapshot.data ?? [];
    return ObservationLogPage(observationEntries: observations);
    }
    },
    ),
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
        final employee = Employee.fromMap(employees.first);
        if (employee.isManager == 1) {
          // Authentication successful for manager
          Navigator.pushNamed(context, '/home');
        } else {
          // Authentication failed for non-manager
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Insufficient Permissions"),
                content: Text("You do not have sufficient permissions to log in."),
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
        title: Text('Hi there!', style: TextStyle(color: Colors.white)), // Set the text and color for the title
        //need to add employee name here
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
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/medal_submission');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green, // Set the button color to green
                          padding: EdgeInsets.all(16.0), // Add padding to the button
                          minimumSize: Size(double.infinity, 0), // Make the button width as wide as the screen
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'Medals',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                            ),
                            Text(
                              'Medals',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/yellow_card');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.yellow, // Set the button color to yellow
                          padding: EdgeInsets.all(16.0), // Add padding to the button
                          minimumSize: Size(double.infinity, 0), // Make the button width as wide as the screen
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'Yellow Card',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                            ),
                            Text(
                              'Yellow Card',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/hygiene_submission');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // Set the button color to red
                          padding: EdgeInsets.all(16.0), // Add padding to the button
                          minimumSize: Size(double.infinity, 0), // Make the button width as wide as the screen
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'Hygiene',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                            ),
                            Text(
                              'Hygiene',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
  bool employeeSelected = false; // Flag to track if an employee has been selected

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
      employeeSelected = true; // Set the flag to true when an employee is selected
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
              if (!employeeSelected)
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
                      searchController.text = '${employee.firstName} ${employee.lastName}';
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
                  onPressed: () {
                    submitMedal();
                    Navigator.pushNamed(context, '/home');
                  },
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


class YellowCardPage extends StatefulWidget {
  @override
  _YellowCardPageState createState() => _YellowCardPageState();
}

class _YellowCardPageState extends State<YellowCardPage> {
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

  Future<void> submitYellowCard() async {
    if (selectedEmployeeId == -1) {
      // No employee selected
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final reason = reasonController.text; // Get the reason from the text field

    final observation = Observation(
      empID: selectedEmployeeId,
      timestamp: timestamp,
      medal: 0, // Assuming a default value of 0 for simplicity
      yellowCard: 1, // Assuming a yellow card value of 1 for simplicity
      hygiene: 0, // Assuming a default value of 0 for simplicity
      reason: reason, // Replace with the actual reason value
    );

    try {
      final db = await DatabaseHelper.database;
      await db.insert('OBSERVATIONS', observation.toMap());
      print('Yellow card submitted successfully!');
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
                  controller: reasonController,
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
                  onPressed: () {
                    submitYellowCard();
                    Navigator.pushNamed(context, '/home');
                  },
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
  final TextEditingController searchController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];

  int selectedEmployeeId = -1; // Default value indicating no employee is selected
  int selectedHygienePoints = 0; // Default value indicating no hygiene points selected

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

  void selectHygienePoints(int points) {
    setState(() {
      selectedHygienePoints = points;
    });
  }

  Future<void> submitHygieneAchievement() async {
    if (selectedEmployeeId == -1 || selectedHygienePoints == 0) {
      // No employee selected or no hygiene points selected
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final reason = reasonController.text; // Get the reason from the text field
    final hygienePoints = selectedHygienePoints;

    final observation = Observation(
      empID: selectedEmployeeId,
      timestamp: timestamp,
      medal: 0, // Assuming a default value of 0 for simplicity
      yellowCard: 0, // Assuming a default value of 0 for simplicity
      hygiene: hygienePoints, // Replace with the actual hygiene points value
      reason: reason, // Replace with the actual reason value
    );

    try {
      final db = await DatabaseHelper.database;
      await db.insert('OBSERVATIONS', observation.toMap());
      print('Hygiene achievement submitted successfully!');
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
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Hygiene Category',
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          value: -1,
                          child: Text('Poor'),
                        ),
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text('Standard'),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Text('Excellent'),
                        ),
                      ],
                      onChanged: (value) {
                        selectHygienePoints(value ?? 0);
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Text('Points:', style: TextStyle(color: Colors.black)),
                  Text(
                    selectedHygienePoints.toString(),
                    style: TextStyle(color: Colors.black),
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
                  controller: reasonController,
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
                  onPressed: () {
                    submitHygieneAchievement();
                    Navigator.pushNamed(context, '/home');
                  },
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


class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Employee> employees = [];
  List<Observation> observations = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchObservations();
  }

  void fetchEmployees() async {
    final database = await DatabaseHelper.database;
    final List<Map<String, dynamic>> employeeMaps = await database.query('EMPLOYEE');

    final List<Employee> employeeList = employeeMaps.map((map) => Employee.fromMap(map)).toList();

    setState(() {
      employees = employeeList;
    });
  }

  void fetchObservations() async {
    final database = await DatabaseHelper.database;
    final List<Map<String, dynamic>> observationMaps = await database.query('OBSERVATIONS');

    final List<Observation> observationList = observationMaps.map((map) => Observation.fromMap(map)).toList();

    setState(() {
      observations = observationList;
    });
  }


  List<LeaderboardEntry> calculateLeaderboard() {
    Map<int, int> totalPointsMap = {};

    for (final observation in observations) {
      final int empID = observation.empID;
      final int medals = observation.medal;
      final int yellowCards = observation.yellowCard;
      final int hygiene = observation.hygiene;

      final int points = medals - yellowCards + hygiene;

      totalPointsMap[empID] = (totalPointsMap[empID] ?? 0) + points;
    }

    List<LeaderboardEntry> leaderboard = [];

    for (final employee in employees) {
      final int empID = employee.empID;
      final bool isManager = employee.isManager == 1;
      final int points = totalPointsMap.containsKey(empID) ? totalPointsMap[empID]! : 0;

      if (!isManager) {
        leaderboard.add(LeaderboardEntry(employee: employee, points: points));
      }
    }

    leaderboard.sort((a, b) => b.points.compareTo(a.points));

    return leaderboard;
  }


  @override
  Widget build(BuildContext context) {
    List<LeaderboardEntry> leaderboard = calculateLeaderboard();

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
                        MaterialPageRoute(
                          builder: (context) => ObservationLogPage(
                            observationEntries: observations,
                          ),
                        ),
                      );
                    },
                    child: Text('View Observation Log'),
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
                  for (int i = 0; i < leaderboard.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? Colors.white : Colors.grey[200],
                      ),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(leaderboard[i].employee.firstName + ' ' + leaderboard[i].employee.lastName),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((i + 1).toString()),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(leaderboard[i].points.toString()),
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

class LeaderboardEntry {
  final Employee employee;
  final int points;

  LeaderboardEntry({required this.employee, required this.points});
}

class ObservationLogPage extends StatelessWidget {
  final List<Observation> observationEntries;

  const ObservationLogPage({required this.observationEntries});

  @override
  Widget build(BuildContext context) {
    // Sort the observationEntries by timestamp in descending order
    observationEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
              Expanded(
                child: ListView.builder(
                  itemCount: observationEntries.length,
                  itemBuilder: (context, index) {
                    final entry = observationEntries[index];

                    return Container(
                      color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          // children: [
                          //   Expanded(
                          //     flex: 2,
                          //     child: Text(
                          //       entry.timestamp,
                          //       style: TextStyle(fontSize: 12),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          //   Expanded(
                          //     flex: 2,
                          //     child: Text(
                          //       '${entry.employee.firstName} ${entry.employee.lastName}',
                          //       style: TextStyle(fontSize: 12),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          //   Expanded(
                          //     flex: 2,
                          //     child: Text(
                          //       '${entry.manager.firstName} ${entry.manager.lastName}',
                          //       style: TextStyle(fontSize: 12),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          //   Expanded(
                          //     flex: 2,
                          //     child: Text(
                          //       entry.type.substring(0, 1),
                          //       style: TextStyle(fontSize: 12),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          // ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
