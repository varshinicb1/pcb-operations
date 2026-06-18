// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) => LeaveRequest(
  id: json['id'] as String,
  employeeId: json['employeeId'] as String,
  employeeName: json['employeeName'] as String,
  branchId: json['branchId'] as String,
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String,
  reason: json['reason'] as String,
  status: json['status'] as String? ?? 'pending',
  adminRemarks: json['adminRemarks'] as String?,
  adminId: json['adminId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LeaveRequestToJson(LeaveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'branchId': instance.branchId,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'reason': instance.reason,
      'status': instance.status,
      'adminRemarks': instance.adminRemarks,
      'adminId': instance.adminId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
