class AppConstants {
  AppConstants._();

  static const String appName = 'PCB Operations';
  static const String appTagline = 'Prakash Coach Builders';

  static const String companyName = 'Prakash Coach Builders';

  static const List<String> productionStages = [
    'Chassis Received',
    'Fabrication',
    'Welding',
    'Sheet Metal',
    'Painting',
    'Electrical',
    'Interior Fitment',
    'Testing',
    'Ready for Delivery',
    'Delivered',
  ];

  static const List<String> departments = [
    'Fabrication',
    'Welding',
    'Sheet Metal',
    'Painting',
    'Electrical',
    'Interior',
    'Testing',
    'Quality',
  ];

  static const int checkoutBeforeHours = 12;
  static const double maxCheckinDistanceKm = 1.0;
  static const int otpExpirySeconds = 300;
  static const int attendanceGraceMinutes = 15;
  static const int lateThresholdMinutes = 10;

  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  static const String androidDownloadUrl =
      'https://prakash-coach-builders.web.app/download';

  static const String supportEmail = 'support@prakashcoach.com';
  static const String supportPhone = '+91-XXXXXXXXXX';
}
