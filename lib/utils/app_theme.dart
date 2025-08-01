import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1565C0), // deep blue
          onPrimary: Colors.white,
          secondary: Color(0xFF263238), // dark blue-grey
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF263238),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Comic Sans MS',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );

  // Color constants
  static const Color landingBg = Color(0xFFFFE4F0);
  static const Color tediColor = Color(0xFF1565C0);
  static const Color abiyeColor = Color.fromARGB(255, 97, 176, 232);
  static const Color abiyeAccent = Color.fromARGB(255, 97, 176, 232);
  static const Color abiyeBg = Color(0xFFF5F7FA); // Same as Tedi - light grey background
  static const Color abiyeCard = Colors.white; // Same as Tedi - white cards
  static const Color abiyeTextColor = Color(0xFF263238); // Same as Tedi - dark blue-grey text
}
