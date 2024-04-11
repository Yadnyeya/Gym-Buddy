import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'gallery_screen.dart';

void main() {
  runApp(GymBuddyApp());
}

class GymBuddyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Buddy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      home: HomePage(),
    );
  }
}
enum NavigationTab { profile, workout, gallery }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NavigationTab _currentTab = NavigationTab.workout;

  void _selectTab(NavigationTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentTab) {
      case NavigationTab.profile:
        return ProfileScreen(); // Now using the ProfileScreen widget
      case NavigationTab.workout:
        return WorkoutScreen(); // WorkoutScreen widget
      case NavigationTab.gallery:
        return GalleryScreen(); // Now using the GalleryScreen widget
      default:
        return Center(child: Text('Unknown'));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Buddy', style: GoogleFonts.bungeeSpice(fontSize: 24)),
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Gallery',
          ),
        ],
        currentIndex: NavigationTab.values.indexOf(_currentTab),
        onTap: (index) => _selectTab(NavigationTab.values[index]),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }
}
