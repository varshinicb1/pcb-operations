import 'package:json_annotation/json_annotation.dart';

part 'leave.g.dart';

@JsonSerializable()
class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String branchId;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? adminRemarks;
  final String? adminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.branchId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'pending',
    this.adminRemarks,
    this.adminId,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  LeaveRequest copyWith({
    String? id, String? employeeId, String? employeeName, String? branchId,
    String? startDate, String? endDate, String? reason, String? status,
    String? adminRemarks, String? adminId, DateTime? createdAt, DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id, employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName, branchId: branchId ?? this.branchId,
      startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason, status: status ?? this.status,
      adminRemarks: adminRemarks ?? this.adminRemarks, adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$LeaveRequestToJson(this);
  factory LeaveRequest.fromJson(Map<String, dynamic> json) => _$LeaveRequestFromJson(json);
}
