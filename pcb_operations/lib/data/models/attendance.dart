import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final String branchId;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String? checkInAddress;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutAddress;
  final String? selfieUrl;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.branchId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAddress,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAddress,
    this.selfieUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;

  bool get isLate => checkInTime != null && checkInTime!.compareTo('09:15') > 0;

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? branchId,
    String? date,
    String? checkInTime,
    String? checkOutTime,
    double? checkInLatitude,
    double? checkInLongitude,
    String? checkInAddress,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? checkOutAddress,
    String? selfieUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkInAddress: checkInAddress ?? this.checkInAddress,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      checkOutAddress: checkOutAddress ?? this.checkOutAddress,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}
