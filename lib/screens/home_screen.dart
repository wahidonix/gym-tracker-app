import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'daily_log_screen.dart';
import 'progress_screen.dart';
import 'user_profile_screen.dart';
import 'exercise_tracking_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    DailyLogScreen(),
    ProgressScreen(),
    ExerciseTrackingScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_selectedIndex)),
        actions: [
          if (_selectedIndex == 3) // Only show settings icon on profile screen
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // This ensures all items are always visible
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Daily Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Daily Log';
      case 1:
        return 'Progress';
      case 2:
        return 'Exercise Tracking';
      case 3:
        return 'Profile';
      default:
        return 'Weight Tracker';
    }
  }
}
