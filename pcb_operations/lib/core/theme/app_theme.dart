import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.border)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accent.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: AppColors.textMuted, size: 22)),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: AppColors.border),
          foregroundColor: AppColors.textPrimary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 0),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.accent,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }
}
