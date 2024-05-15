import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';  // Assuming RegisterScreen is properly defined elsewhere
import 'profile_screen.dart';   // Assuming ProfileScreen is properly defined elsewhere
import 'workout_screen.dart';   // Assuming WorkoutScreen is properly defined elsewhere
import 'gallery_screen.dart';   // Assuming GalleryScreen is properly defined elsewhere

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: RegisterScreen(),
    );
  }
}

enum NavigationTab { profile, workout, gallery }

class HomePage extends StatefulWidget {
  final NavigationTab initialTab;

  HomePage({this.initialTab = NavigationTab.workout});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NavigationTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;  // Initialize with the initialTab provided
  }

  void _selectTab(NavigationTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentTab) {
      case NavigationTab.profile:
        return ProfileScreen();  // Now using the ProfileScreen widget
      case NavigationTab.workout:
        return WorkoutScreen();  // WorkoutScreen widget
      case NavigationTab.gallery:
        return GalleryScreen();  // Now using the GalleryScreen widget
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
