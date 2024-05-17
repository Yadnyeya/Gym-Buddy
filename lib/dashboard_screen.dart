import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/settings_screen.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'login_screen.dart'; // Ensure you have a LoginScreen defined

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late StreamSubscription<StepCount> _stepCountStream;
  String _steps = '0';
  int _calories = 0;
  Timer? _activeTimer;
  Timer? _midnightResetTimer;
  int _activeMinutes = 0;
  int _waterIntake = 0;
  double _distanceInMiles = 0.0;
  late String _userId;
  String _username = 'User';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  List<SensorValue> data = [];
  List<SensorValue> bpmValues = [];
  bool isBPMEnabled = false;
  Widget? dialog;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _fetchUserData();
    _startActiveTimer();
    initPlatformState();
    _scheduleMidnightReset();
  }

  Future<void> requestPermissions() async {
    await Permission.activityRecognition.request();
  }

  void _fetchUserData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      var userDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      setState(() {
        _username = userDoc.data()?['username'] ?? 'User';
        _steps = userDoc.data()?['steps']?.toString() ?? '0';
        _calories = userDoc.data()?['calories']?.toInt() ?? 0;
        _activeMinutes = userDoc.data()?['activeMinutes']?.toInt() ?? 0;
        _waterIntake = userDoc.data()?['waterIntake']?.toInt() ?? 0;
        _distanceInMiles =
            userDoc.data()?['distanceInMiles']?.toDouble() ?? 0.0;
      });
    }
  }

  void _startActiveTimer() {
    _activeTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        setState(() {
          _activeMinutes++;
          _updateFirestore(int.parse(_steps), _distanceInMiles);
        });
      }
    });
  }

  void _scheduleMidnightReset() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = midnight.difference(now);

    _midnightResetTimer = Timer(durationUntilMidnight, _resetDailyStats);
  }

  void _resetDailyStats() {
    setState(() {
      _steps = '0';
      _calories = 0;
      _activeMinutes = 0;
      _waterIntake = 0;
      _distanceInMiles = 0.0;
    });

    _updateFirestore(0, 0.0);

    _scheduleMidnightReset();
  }

  void onStepCount(StepCount event) {
    print("New step count event: ${event.steps}");
    int newSteps = int.parse(_steps) + event.steps;
    double newDistanceInMiles =
        (newSteps * 2.5) / 5280; // Calculate distance in miles
    setState(() {
      _steps = newSteps.toString();
      _calories =
          (newSteps * 0.045).round(); // Calculate calories based on steps
      _distanceInMiles = newDistanceInMiles;
    });
    _updateFirestore(newSteps, newDistanceInMiles);
  }

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream.listen(
      onStepCount,
      onError: onStepCountError,
      cancelOnError: true,
    );
  }

  void onStepCountError(error) {
    print('Step Count Error: $error');
    setState(() {
      _steps = 'Error retrieving steps';
    });
  }

  void _updateFirestore(int newSteps, double newDistanceInMiles) {
    FirebaseFirestore.instance.collection('clients').doc(_userId).update({
      'steps': newSteps,
      'calories': _calories,
      'activeMinutes': _activeMinutes,
      'waterIntake': _waterIntake,
      'distanceInMiles': newDistanceInMiles,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        title: Text("Dashboard"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: _openSettings),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendar(),
            _buildRunInfo(),
            SizedBox(height: 20),
            _buildStatsCard(),
            SizedBox(height: 20),
            // Center(
            //   child: ElevatedButton.icon(
            //     icon: Icon(Icons.favorite_rounded),
            //     label: Text(isBPMEnabled ? "Stop measurement" : "Measure"),
            //     onPressed: () => setState(() {
            //       if (isBPMEnabled) {
            //         isBPMEnabled = false;
            //       } else {
            //         isBPMEnabled = true;
            //       }
            //     }),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String greetingMessage() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning,';
      } else if (hour < 17) {
        return 'Good Afternoon,';
      } else {
        return 'Good Evening,';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingMessage(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          Text(
            _username,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: <Color>[
                    Colors.white,
                    Color(0xFF6279E4),
                  ],
                ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFFFF6F61),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF6279E4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildRunInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Image.asset(
              'assets/running.png', // Path to your running person image
              height: 150, // Increased size
            ),
          ),
          SizedBox(width: 16), // Add space between image and text
          Flexible(
            // flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today you ran\n \t\t\t\t\t\t\t\t\tfor\n',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_distanceInMiles.toStringAsFixed(2)} mi',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6279E4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side big container for steps
              Container(
                width:
                    MediaQuery.of(context).size.width * 0.3, // Set fixed width
                height: 210, // Set fixed height
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                      255, 219, 166, 117), // Change to desired color
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_walk, size: 36, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      '$_steps',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'steps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Right side three containers
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 65,
                      width: 300, // Set fixed height
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                            255, 213, 132, 132), // Change to desired color
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department,
                              size: 24, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            '$_calories',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 65, // Set fixed height
                      width: 300,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 119, 145, 90), // Change to desired color
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, size: 24, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            '$_activeMinutes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'mins',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 65, // Set fixed height
                      width: 300,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                            255, 116, 161, 198), // Change to desired color
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop, size: 24, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            '$_waterIntake',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'bottles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_waterIntake > 0) {
                                setState(() => _waterIntake--);
                                _updateWaterIntakeInFirestore(_waterIntake);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(2), // Background color
                              minimumSize: Size(36, 36),
                            ),
                            child: Icon(Icons.remove,
                                color: Colors.black, size: 20),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _waterIntake++);
                              _updateWaterIntakeInFirestore(_waterIntake);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(2), // Background color
                              minimumSize: Size(36, 36),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Bottom container for heart rate monitor
          Container(
            width: double.infinity, // Take full width
            height: isBPMEnabled ? 182 : 100, // Dynamic height
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Color.fromARGB(255, 255, 135, 175), // Change to desired color
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildHeartRateMonitor(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.yellow),
          SizedBox(width: 16),
          Text(
            data,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.water_drop, size: 24, color: Colors.white),
          SizedBox(width: 16),
          Text(
            '$_waterIntake bottles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_waterIntake > 0) {
                setState(() => _waterIntake--);
                _updateWaterIntakeInFirestore(_waterIntake);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(), backgroundColor: Colors.red,
              padding: EdgeInsets.all(8), // Background color
            ),
            child: Icon(Icons.remove, color: Colors.white),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              setState(() => _waterIntake++);
              _updateWaterIntakeInFirestore(_waterIntake);
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(), backgroundColor: Colors.green,
              padding: EdgeInsets.all(8), // Background color
            ),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _updateWaterIntakeInFirestore(int waterIntake) {
    FirebaseFirestore.instance.collection('clients').doc(_userId).update({
      'waterIntake': waterIntake,
    });
  }

  Widget _buildRoundedButton(IconData icon, VoidCallback onPressed,
      {required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        shape: CircleBorder(),
        padding: EdgeInsets.all(8), // Icon color
      ),
      child: Icon(icon),
    );
  }

  Widget _buildHeartRateMonitor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.pink,
                size: 45,
              ),
              Text(
                isBPMEnabled && bpmValues.isNotEmpty
                    ? '${bpmValues.last.value.toInt()} bpm'
                    : 'BMP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 1), // Add space between heart icon and button
        SizedBox(
          width: 100, // Set the width of the button
          height: 36, // Set the height of the button
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isBPMEnabled = !isBPMEnabled;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set the background color
              padding: EdgeInsets.all(8), // Padding for the button
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Border radius for the button
              ),
            ),
            child: Text(
              isBPMEnabled ? 'Stop' : 'Measure BPM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10, // Make the inside text small
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(width: 16),
        if (isBPMEnabled)
          HeartBPMDialog(
            context: context,
            showTextValues: true,
            borderRadius: 10,
            onRawData: (value) {
              setState(() {
                if (data.length >= 100) data.removeAt(0);
                data.add(value);
              });
            },
            onBPM: (value) => setState(() {
              if (bpmValues.length >= 100) bpmValues.removeAt(0);
              bpmValues.add(
                  SensorValue(value: value.toDouble(), time: DateTime.now()));
            }),
          ),
      ],
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  void dispose() {
    _stepCountStream.cancel();
    _activeTimer?.cancel();
    _midnightResetTimer?.cancel();
    super.dispose();
  }
}
