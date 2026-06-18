// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyReport _$DailyReportFromJson(Map<String, dynamic> json) => DailyReport(
  id: json['id'] as String,
  branchId: json['branchId'] as String,
  department: json['department'] as String,
  date: json['date'] as String,
  submittedBy: json['submittedBy'] as String,
  submittedByName: json['submittedByName'] as String,
  busUpdates: json['busUpdates'] as String?,
  productionIssues: json['productionIssues'] as String?,
  materialDelays: json['materialDelays'] as String?,
  workforceIssues: json['workforceIssues'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DailyReportToJson(DailyReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'department': instance.department,
      'date': instance.date,
      'submittedBy': instance.submittedBy,
      'submittedByName': instance.submittedByName,
      'busUpdates': instance.busUpdates,
      'productionIssues': instance.productionIssues,
      'materialDelays': instance.materialDelays,
      'workforceIssues': instance.workforceIssues,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
