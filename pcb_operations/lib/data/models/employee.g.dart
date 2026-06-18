// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  id: json['id'] as String,
  employeeId: json['employeeId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  photoUrl: json['photoUrl'] as String?,
  designation: json['designation'] as String,
  department: json['department'] as String,
  branchId: json['branchId'] as String,
  branchName: json['branchName'] as String,
  role: json['role'] as String,
  isActive: json['isActive'] as bool? ?? true,
  joinDate: json['joinDate'] == null
      ? null
      : DateTime.parse(json['joinDate'] as String),
  address: json['address'] as String?,
  emergencyContact: json['emergencyContact'] as String?,
  emergencyName: json['emergencyName'] as String?,
  isCheckedIn: json['isCheckedIn'] as bool? ?? false,
  lastCheckIn: json['lastCheckIn'] == null
      ? null
      : DateTime.parse(json['lastCheckIn'] as String),
  lastCheckOut: json['lastCheckOut'] == null
      ? null
      : DateTime.parse(json['lastCheckOut'] as String),
  lastLatitude: (json['lastLatitude'] as num?)?.toDouble(),
  lastLongitude: (json['lastLongitude'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'id': instance.id,
  'employeeId': instance.employeeId,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'photoUrl': instance.photoUrl,
  'designation': instance.designation,
  'department': instance.department,
  'branchId': instance.branchId,
  'branchName': instance.branchName,
  'role': instance.role,
  'isActive': instance.isActive,
  'joinDate': instance.joinDate?.toIso8601String(),
  'address': instance.address,
  'emergencyContact': instance.emergencyContact,
  'emergencyName': instance.emergencyName,
  'isCheckedIn': instance.isCheckedIn,
  'lastCheckIn': instance.lastCheckIn?.toIso8601String(),
  'lastCheckOut': instance.lastCheckOut?.toIso8601String(),
  'lastLatitude': instance.lastLatitude,
  'lastLongitude': instance.lastLongitude,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
