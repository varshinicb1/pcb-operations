// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branch _$BranchFromJson(Map<String, dynamic> json) => Branch(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool? ?? true,
  employeeCount: (json['employeeCount'] as num?)?.toInt(),
  activeProjects: (json['activeProjects'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BranchToJson(Branch instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'phone': instance.phone,
  'email': instance.email,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'isActive': instance.isActive,
  'employeeCount': instance.employeeCount,
  'activeProjects': instance.activeProjects,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
