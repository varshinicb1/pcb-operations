// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bus _$BusFromJson(Map<String, dynamic> json) => Bus(
  id: json['id'] as String,
  busNumber: json['busNumber'] as String,
  chassisNumber: json['chassisNumber'] as String,
  model: json['model'] as String,
  customerName: json['customerName'] as String,
  branchId: json['branchId'] as String,
  currentStage: json['currentStage'] as String,
  currentStageIndex: (json['currentStageIndex'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'active',
  photoUrl: json['photoUrl'] as String?,
  lastRemarks: json['lastRemarks'] as String?,
  lastUpdatedBy: json['lastUpdatedBy'] as String?,
  lastUpdatedByName: json['lastUpdatedByName'] as String?,
  deliveryDate: json['deliveryDate'] == null
      ? null
      : DateTime.parse(json['deliveryDate'] as String),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BusToJson(Bus instance) => <String, dynamic>{
  'id': instance.id,
  'busNumber': instance.busNumber,
  'chassisNumber': instance.chassisNumber,
  'model': instance.model,
  'customerName': instance.customerName,
  'branchId': instance.branchId,
  'currentStage': instance.currentStage,
  'currentStageIndex': instance.currentStageIndex,
  'status': instance.status,
  'photoUrl': instance.photoUrl,
  'lastRemarks': instance.lastRemarks,
  'lastUpdatedBy': instance.lastUpdatedBy,
  'lastUpdatedByName': instance.lastUpdatedByName,
  'deliveryDate': instance.deliveryDate?.toIso8601String(),
  'startDate': instance.startDate?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

ProductionUpdate _$ProductionUpdateFromJson(Map<String, dynamic> json) =>
    ProductionUpdate(
      id: json['id'] as String,
      busId: json['busId'] as String,
      stage: json['stage'] as String,
      stageIndex: (json['stageIndex'] as num).toInt(),
      photoBase64: json['photoBase64'] as String?,
      remarks: json['remarks'] as String?,
      updatedBy: json['updatedBy'] as String,
      updatedByName: json['updatedByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProductionUpdateToJson(ProductionUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'busId': instance.busId,
      'stage': instance.stage,
      'stageIndex': instance.stageIndex,
      'photoBase64': instance.photoBase64,
      'remarks': instance.remarks,
      'updatedBy': instance.updatedBy,
      'updatedByName': instance.updatedByName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
