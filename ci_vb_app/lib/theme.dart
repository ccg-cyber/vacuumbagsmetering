// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kBrandBlue = Color(0xFF1565C0);
const kBrandCyan = Color(0xFF0097A7);
const kBrandDark = Color(0xFF0D1B2A);
const kCardLight = Color(0xFFF7F9FB);
const kCardDark = Color(0xFF1A2536);
const kResultGreen = Color(0xFF00897B);
const kResultOrange = Color(0xFFE65100);

ThemeData lightTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: kBrandBlue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFEFF3F8),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kCardLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrandBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );

ThemeData darkTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: kBrandCyan,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBrandDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        color: kCardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF243044),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF374B65))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF374B65))),
      ),
    );
