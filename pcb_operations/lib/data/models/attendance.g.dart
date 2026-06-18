// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
  id: json['id'] as String,
  employeeId: json['employeeId'] as String,
  employeeName: json['employeeName'] as String,
  branchId: json['branchId'] as String,
  date: json['date'] as String,
  checkInTime: json['checkInTime'] as String?,
  checkOutTime: json['checkOutTime'] as String?,
  checkInLatitude: (json['checkInLatitude'] as num?)?.toDouble(),
  checkInLongitude: (json['checkInLongitude'] as num?)?.toDouble(),
  checkInAddress: json['checkInAddress'] as String?,
  checkOutLatitude: (json['checkOutLatitude'] as num?)?.toDouble(),
  checkOutLongitude: (json['checkOutLongitude'] as num?)?.toDouble(),
  checkOutAddress: json['checkOutAddress'] as String?,
  selfieUrl: json['selfieUrl'] as String?,
  verificationStatus: json['verificationStatus'] as String?,
  referenceFaceId: json['referenceFaceId'] as String?,
  status: json['status'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'branchId': instance.branchId,
      'date': instance.date,
      'checkInTime': instance.checkInTime,
      'checkOutTime': instance.checkOutTime,
      'checkInLatitude': instance.checkInLatitude,
      'checkInLongitude': instance.checkInLongitude,
      'checkInAddress': instance.checkInAddress,
      'checkOutLatitude': instance.checkOutLatitude,
      'checkOutLongitude': instance.checkOutLongitude,
      'checkOutAddress': instance.checkOutAddress,
      'selfieUrl': instance.selfieUrl,
      'verificationStatus': instance.verificationStatus,
      'referenceFaceId': instance.referenceFaceId,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
