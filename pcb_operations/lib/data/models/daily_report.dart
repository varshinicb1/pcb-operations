import 'package:json_annotation/json_annotation.dart';

part 'daily_report.g.dart';

@JsonSerializable()
class DailyReport {
  final String id;
  final String branchId;
  final String department;
  final String date;
  final String submittedBy;
  final String submittedByName;
  final String? busUpdates;
  final String? productionIssues;
  final String? materialDelays;
  final String? workforceIssues;
  final String? notes;
  final DateTime? createdAt;

  const DailyReport({
    required this.id, required this.branchId, required this.department,
    required this.date, required this.submittedBy, required this.submittedByName,
    this.busUpdates, this.productionIssues, this.materialDelays,
    this.workforceIssues, this.notes, this.createdAt,
  });

  Map<String, dynamic> toJson() => _$DailyReportToJson(this);
  factory DailyReport.fromJson(Map<String, dynamic> json) => _$DailyReportFromJson(json);
}
