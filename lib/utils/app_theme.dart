import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFFD600);
  static const Color secondaryColor = Color(0xFF303030);
  static const Color backgroundColor = Colors.white;

  static TextStyle headingStyle({
    
    double size = 24,
    FontWeight weight = FontWeight.bold,
    Color color = secondaryColor,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle contentStyle({
    double size = 16,
    FontWeight weight = FontWeight.normal,
    Color color = secondaryColor,
  }) {
    return TextStyle(
      fontFamily: 'Urbanist',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
  );
}
