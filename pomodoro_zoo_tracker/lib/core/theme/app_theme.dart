import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // แนะนำให้ลง package นี้เพิ่มครับ
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      // กำหนด Font ตาม HTML (Plus Jakarta Sans สำหรับหัวข้อ, Inter สำหรับเนื้อหา)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      // ปรับปุ่มให้โค้งมน (Border Radius: 3rem / full)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          elevation: 0,
        ),
      ),
    );
  }
}