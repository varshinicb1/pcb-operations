import 'package:json_annotation/json_annotation.dart';

part 'bus.g.dart';

@JsonSerializable()
class Bus {
  final String id;
  final String busNumber;
  final String chassisNumber;
  final String model;
  final String customerName;
  final String branchId;
  final String currentStage;
  final int currentStageIndex;
  final String status;
  final String? photoUrl;
  final String? lastRemarks;
  final String? lastUpdatedBy;
  final String? lastUpdatedByName;
  final DateTime? deliveryDate;
  final DateTime? startDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Bus({
    required this.id, required this.busNumber, required this.chassisNumber,
    required this.model, required this.customerName, required this.branchId,
    required this.currentStage, this.currentStageIndex = 0,
    this.status = 'active', this.photoUrl, this.lastRemarks,
    this.lastUpdatedBy, this.lastUpdatedByName,
    this.deliveryDate, this.startDate,
    this.createdAt, this.updatedAt,
  });

  double get completionPercent => (currentStageIndex / 10) * 100;

  bool get isDelivered => currentStage == 'Delivered';
  bool get isDelayed => deliveryDate != null && deliveryDate!.isBefore(DateTime.now()) && !isDelivered;

  Map<String, dynamic> toJson() => _$BusToJson(this);
  factory Bus.fromJson(Map<String, dynamic> json) => _$BusFromJson(json);
}

@JsonSerializable()
class ProductionUpdate {
  final String id;
  final String busId;
  final String stage;
  final int stageIndex;
  final String? photoBase64;
  final String? remarks;
  final String updatedBy;
  final String updatedByName;
  final DateTime createdAt;

  const ProductionUpdate({
    required this.id, required this.busId, required this.stage,
    required this.stageIndex, this.photoBase64, this.remarks,
    required this.updatedBy, required this.updatedByName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => _$ProductionUpdateToJson(this);
  factory ProductionUpdate.fromJson(Map<String, dynamic> json) => _$ProductionUpdateFromJson(json);
}
