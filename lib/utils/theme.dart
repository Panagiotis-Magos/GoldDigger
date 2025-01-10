import 'package:flutter/material.dart';

//testing

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.amber, // Amber primary color for a vibrant look
      brightness: Brightness.dark, // Dark theme to match your app's style
      scaffoldBackgroundColor: const Color(0xFF333333), // Dark gray background
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.amber, // App bar color matches the primary swatch
        foregroundColor: Colors.black, // Black text/icons on the app bar
        elevation: 4, // Slight shadow for app bar
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ), // Headings for screens
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ), // Regular text
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ), // Subdued text
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[600], // Input field background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: const TextStyle(color: Colors.white70), // Placeholder text color
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600], // Button background color
          foregroundColor: Colors.white, // Button text color
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF333333), // Matches the scaffold background
        selectedItemColor: Colors.amber, // Highlight for selected items
        unselectedItemColor: Colors.grey, // Grayed-out unselected items
      ),
    );
  }
}
