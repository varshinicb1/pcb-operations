import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primaryDark = Color(0xFF111D44);
  static const primary = Color(0xFF192A56);
  static const primaryLight = Color(0xFF27386D);

  static const accent = Color(0xFFFCAD19);
  static const accentDark = Color(0xFFE09A14);
  static const accentLight = Color(0xFFFDBD3D);

  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFEF2F2);

  static const surface = Color(0xFFF5F7FA);
  static const surfaceDark = Color(0xFF0A1128);
  static const card = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF152040);

  static const textPrimary = Color(0xFF111D44);
  static const textSecondary = Color(0xFF6B7A99);
  static const textOnDark = Color(0xFFF0F2F5);
  static const textMuted = Color(0xFF9CA3AF);

  static const border = Color(0xFFE8ECF1);
  static const borderDark = Color(0xFF27386D);

  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFECFDF5);
  static const warning = Color(0xFFFCAD19);
  static const warningBg = Color(0xFFFFFBEB);
  static const info = Color(0xFF3B82F6);

  static const attendancePresent = success;
  static const attendanceAbsent = error;
  static const attendanceLate = accent;

  static const List<Color> productionStages = [
    Color(0xFF6B7280), Color(0xFF3B82F6), Color(0xFF8B5CF6),
    Color(0xFFEC4899), Color(0xFFFCAD19), Color(0xFF10B981),
    Color(0xFF06B6D4), Color(0xFF6366F1), Color(0xFF22C55E),
    Color(0xFF14B8A6),
  ];
}
