import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, 
          brightness: Brightness.dark, 
        ),
        useMaterial3: true, // Optional, for Material 3 styling
        scaffoldBackgroundColor: const Color(0xFF2F3E46),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF52796F),
          foregroundColor: Color(0xFFCAD2C5),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF52796F),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
