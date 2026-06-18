import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get formatted => DateFormat('dd MMM yyyy').format(this);
  String get formattedTime => DateFormat('hh:mm a').format(this);
  String get formattedDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  String get relativeDay {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return formatted;
  }
}

extension StringCapitalize on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}

extension ContextExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
}
