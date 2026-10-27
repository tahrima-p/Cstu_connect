import 'package:flutter/material.dart';

class AppTheme {
  // ─── Official CSTU Logo Palette ───────────────────────────────────────────
  // Extracted directly from assets/images.png
  static const Color cstuGold = Color(0xFFEAA22E);       // Technology, Globe & Cursor Wing
  static const Color cstuSlate = Color(0xFF6E7175);      // Science, Atom & Research Wing
  static const Color cstuDark = Color(0xFF18181B);       // Obsidian frame & high-contrast text
  static const Color cstuNavy = Color(0xFF0F172A);       // Deep collegiate navy
  static const Color cstuRiverCyan = Color(0xFF0284C7);   // Chandpur Meghna-Padma confluence blue
  static const Color cstuEmerald = Color(0xFF10B981);     // Active status, Found, RSVP open
  static const Color cstuCrimson = Color(0xFFF43F5E);     // Urgent alert, Lost report
  static const Color background = Color(0xFFF8FAFC);      // Crisp, warm canvas
  static const Color surface = Colors.white;

  // Modern UI Light & Dark Accent Helpers
  static const Color cardColor = Colors.white;
  static const Color cstuGoldLight = Color(0xFFFFFBEB);
  static const Color cstuGoldBorder = Color(0xFFFDE68A);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Backward-compatibility aliases
  static const Color cstuOrange = cstuGold;
  static const Color cstuGray = cstuSlate;
  static const Color orangeLightBg = cstuGoldLight;
  static const Color orangeBorder = cstuGoldBorder;

  // ─── Radii & Geometry ────────────────────────────────────────────────────
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusCard = 20.0;
  static const double radiusPill = 30.0;

  // ─── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF3AB35), Color(0xFFDE9320)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFFFDF7), Color(0xFFFFF7ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ─────────────────────────────────────────────────────────────
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: cstuNavy.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: cstuNavy.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> dockShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> goldGlow = [
    BoxShadow(
      color: cstuGold.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ─── ThemeData ───────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: null, // Uses default crisp system font
    colorScheme: ColorScheme.fromSeed(
      seedColor: cstuGold,
      primary: cstuGold,
      onPrimary: Colors.white,
      secondary: cstuDark,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: cstuDark,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: cstuDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: cstuDark,
        letterSpacing: -0.4,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCard),
        side: const BorderSide(
          color: borderLight,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cstuGold,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cstuGold,
        side: const BorderSide(color: cstuGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: cstuGold,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: cstuGold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: cstuCrimson, width: 1.5),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      indicatorColor: cstuGold.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: cstuGold, size: 24);
        }
        return const IconThemeData(color: cstuSlate, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: cstuGold,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: cstuSlate,
        );
      }),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: cstuGold,
      unselectedLabelColor: cstuSlate,
      indicatorColor: cstuGold,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );
}