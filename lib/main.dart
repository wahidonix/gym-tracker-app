import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'helpers/database_helper.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gym Tracker',
          theme: themeProvider.currentTheme,
          home: FutureBuilder<bool>(
            future: DatabaseHelper().hasUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasData && snapshot.data!) {
                return HomeScreen();
              } else {
                return ProfileSetupScreen();
              }
            },
          ),
          routes: {
            '/home': (context) => HomeScreen(),
            '/profile_setup': (context) => ProfileSetupScreen(),
          },
        );
      },
    );
  }
}
