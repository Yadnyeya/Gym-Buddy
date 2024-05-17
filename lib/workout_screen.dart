import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String name;
  final String description;
  final int duration; // Duration for the exercise in seconds
  final int reps;
  final int sets;
  final int rest; // Rest time in seconds after the exercise
  final String imagePath;

  Exercise({
    required this.name,
    required this.description,
    required this.duration,
    required this.reps,
    required this.sets,
    required this.rest,
    required this.imagePath,
  });
}

List<Exercise> exercises = [
  Exercise(
    name: 'Push-ups',
    description:
        'Perform a standard push-up. Engage your core and keep your back straight while lowering and raising your body.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/pushups.jpg',
  ),
  Exercise(
    name: 'Crunches',
    description:
        'Perform standard crunches. Keep your feet flat on the ground and use your abs to lift your shoulders off the mat.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/crunches.jpg',
  ),
  Exercise(
    name: 'Plank',
    description:
        'Hold a plank position. Maintain a straight line from your head to your heels and keep your core tight.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/plank.jpg',
  ),
  Exercise(
    name: 'Squats',
    description:
        'Perform standard squats. Keep your feet shoulder-width apart and lower your hips as if sitting in a chair.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/squats.jpg',
  ),
  Exercise(
    name: 'Lunges',
    description:
        'Perform alternating lunges. Step forward with one leg and lower your hips until both knees are bent at about 90 degrees.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/lunges.jpg',
  ),
  Exercise(
    name: 'Burpees',
    description:
        'Perform burpees. Start in a standing position, drop into a squat, kick your feet back into a plank, return to squat, and jump up.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/burpees.jpg',
  ),
  Exercise(
    name: 'Mountain Climbers',
    description:
        'Perform mountain climbers. Start in a plank position and alternate bringing your knees towards your chest as quickly as possible.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/mountain_climbers.jpg',
  ),
  Exercise(
    name: 'Bicycle Crunches',
    description:
        'Perform bicycle crunches. Lie on your back and alternate bringing your elbow to the opposite knee while extending the other leg.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/bicycle_crunches.jpg',
  ),
  Exercise(
    name: 'Leg Raises',
    description:
        'Perform leg raises. Lie on your back with your legs straight and lift them towards the ceiling while keeping your core engaged.',
    duration: 30,
    reps: 10,
    sets: 3,
    rest: 10,
    imagePath: 'assets/leg_raises.jpg',
  ),
];

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _username = "User";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? "User";
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "Start Activity",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
          ),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ExerciseDetailScreen(
                    exerciseIndex: index,
                  ),
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 24, 24, 24),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      // color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      exercises[index].imagePath,
                      height: 50,
                      color: Color(0xFF6279E4),
                    ),
                    SizedBox(height: 10),
                    Text(
                      exercises[index].name,
                      style: TextStyle(
                        color: Color(0xFF6279E4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExerciseDetailScreen extends StatefulWidget {
  final int exerciseIndex;

  ExerciseDetailScreen({required this.exerciseIndex});

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingTime = 0;
  bool _isRunning = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _remainingTime = exercises[widget.exerciseIndex].duration;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _remainingTime),
    );
  }

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _controller.forward(from: 0.0);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          setState(() => _remainingTime--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
  }

  void stopTimer() {
    if (_isRunning) {
      _controller.stop();
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exercises[widget.exerciseIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                exercise.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              exercise.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              exercise.imagePath,
              height: 250,
            ),
            SizedBox(height: 20),
            Text(
              exercise.description,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width:
                      100, // Increase the width to make the circular indicator larger
                  height:
                      100, // Increase the height to make the circular indicator larger
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 8.0,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6279E4)),
                  ),
                ),
                Text(
                  '${_remainingTime}s',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6279E4),
                    padding: EdgeInsets.zero, // Remove padding for square shape
                    fixedSize: Size(60, 60), // Square button
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Small rounded corners
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 42.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // More rounded corners
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pause, color: Colors.white, size: 42.0),
                      SizedBox(width: 5), // Space between icon and text
                      Text('Pause', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for the login screen
    return Scaffold(
      body: Center(child: Text("Login Screen")),
    );
  }
}
