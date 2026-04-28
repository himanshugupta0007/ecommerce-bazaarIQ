import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const bg = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const card = Color(0xFF1C2128);
  static const cardBorder = Color(0xFF30363D);
  static const accent = Color(0xFF58A6FF);
  static const accentGreen = Color(0xFF3FB950);
  static const accentRed = Color(0xFFF85149);
  static const accentAmber = Color(0xFFD29922);
  static const accentPurple = Color(0xFFBC8CFF);
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecond = Color(0xFF8B949E);
  static const textMuted = Color(0xFF484F58);
  static const divider = Color(0xFF21262D);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentGreen,
          surface: surface,
          error: accentRed,
        ),
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyMedium: GoogleFonts.inter(color: textPrimary, fontSize: 14),
          bodySmall: GoogleFonts.inter(color: textSecond, fontSize: 12),
          titleMedium: GoogleFonts.inter(
              color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.inter(
              color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
              color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: cardBorder, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: cardBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: cardBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accent, width: 2)),
          labelStyle: const TextStyle(color: textSecond),
          hintStyle: const TextStyle(color: textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: bg,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surface,
          selectedColor: accent.withOpacity(0.2),
          labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
          side: const BorderSide(color: cardBorder),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: bg,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: accent,
          unselectedLabelColor: textSecond,
          indicatorColor: accent,
        ),
        dividerColor: divider,
      );
}

class Fmt {
  static String currency(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  static String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';
  static String num(double v) => v.toStringAsFixed(2);
  static String compact(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

Color acosColor(double acos) {
  if (acos == 0) return AppTheme.textMuted;
  if (acos < 0.25) return AppTheme.accentGreen;
  if (acos < 0.4) return AppTheme.accentAmber;
  return AppTheme.accentRed;
}

Color healthColor(int score) {
  if (score >= 80) return AppTheme.accentGreen;
  if (score >= 60) return AppTheme.accentAmber;
  return AppTheme.accentRed;
}

Color actionColor(String action) {
  if (action.contains('HARVEST')) return AppTheme.accentGreen;
  if (action.contains('WATCH')) return AppTheme.accentAmber;
  if (action.contains('NEGATIVE')) return AppTheme.accentRed;
  if (action.contains('REDUCE')) return const Color(0xFFD29922);
  return AppTheme.textMuted;
}
