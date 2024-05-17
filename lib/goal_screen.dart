import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  int _currentGoal = 600;

  @override
  void initState() {
    super.initState();
    _fetchCurrentGoal();
  }

  void _fetchCurrentGoal() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      setState(() {
        _currentGoal = userDoc.data()?['my_goal'] ?? 600;
      });
    }
  }

  void _updateGoal(int newGoal) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .update({'my_goal': newGoal});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Goal updated successfully'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        title: Text(
          'Your Goals',
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Daily Move Goal',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Set a goal based on how active you are,\nor how active you\'d like to be, each day.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.white70),
            ),
            SizedBox(height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle,
                      color: Color(0xFF6279E4), size: 60),
                  onPressed: () {
                    setState(() {
                      if (_currentGoal > 0) _currentGoal -= 50;
                    });
                  },
                ),
                SizedBox(width: 32),
                Text(
                  '$_currentGoal',
                  style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(width: 32),
                IconButton(
                  icon: Icon(Icons.add_circle,
                      color: Color(0xFF6279E4), size: 60),
                  onPressed: () {
                    setState(() {
                      _currentGoal += 50;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'CALORIES/DAY',
              style: TextStyle(fontSize: 16.0, color: Colors.white70),
            ),
            SizedBox(height: 200),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _updateGoal(_currentGoal);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Set the border radius
                  ),
                ),
                child: Text(
                  'Change Move Goal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
