import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class Helpers {
  Helpers._();

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static String formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  static String productionStageProgress(int currentStage) {
    return '$currentStage/10';
  }

  static double productionStagePercent(int currentStage) {
    return currentStage / 10;
  }

  static Color productionStageColor(int index) {
    return AppColors.productionStages[index % AppColors.productionStages.length];
  }

  static Color attendanceStatusColor(String? status) {
    switch (status) {
      case 'present':
        return AppColors.attendancePresent;
      case 'absent':
        return AppColors.attendanceAbsent;
      case 'late':
        return AppColors.attendanceLate;
      default:
        return AppColors.textSecondary;
    }
  }

  static String attendanceStatusLabel(String? status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      default:
        return 'Unknown';
    }
  }
}
