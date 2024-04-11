import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gym Buddy',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWelcomeSection(context),
            _buildSummaryCards(context),
            // ... Add other UI components here
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
            radius: 30,
          ),
          Expanded(
            child: Text(
              ' Welcome back!\nYour daily summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Today's achievements\nGreat progress!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Duration', '3 hours 30', Icons.access_time),
                _buildSummaryCard('Distance', '8.2 km', Icons.map),
                _buildSummaryCard('Heart Rate', '120 bpm', Icons.favorite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData iconData) {
    return Column(
      children: [
        Icon(
          iconData,
          size: 48,
          color: Colors.orange,
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
