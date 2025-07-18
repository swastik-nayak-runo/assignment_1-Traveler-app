import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {

  return ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: const Color(0xFFE4EDF2),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE4EDF2),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1F23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
