import 'package:json_annotation/json_annotation.dart';

part 'branch.g.dart';

@JsonSerializable()
class Branch {
  final String id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final int? employeeCount;
  final int? activeProjects;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.employeeCount,
    this.activeProjects,
    this.createdAt,
    this.updatedAt,
  });

  Branch copyWith({
    String? id,
    String? name,
    String? code,
    String? address,
    String? city,
    String? state,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    bool? isActive,
    int? employeeCount,
    int? activeProjects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      employeeCount: employeeCount ?? this.employeeCount,
      activeProjects: activeProjects ?? this.activeProjects,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$BranchToJson(this);

  factory Branch.fromJson(Map<String, dynamic> json) =>
      _$BranchFromJson(json);
}
