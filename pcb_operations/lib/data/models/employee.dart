import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String designation;
  final String department;
  final String branchId;
  final String branchName;
  final String role;
  final bool isActive;
  final DateTime? joinDate;
  final String? address;
  final String? emergencyContact;
  final String? emergencyName;
  final bool isCheckedIn;
  final DateTime? lastCheckIn;
  final DateTime? lastCheckOut;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.designation,
    required this.department,
    required this.branchId,
    required this.branchName,
    required this.role,
    this.isActive = true,
    this.joinDate,
    this.address,
    this.emergencyContact,
    this.emergencyName,
    this.isCheckedIn = false,
    this.lastCheckIn,
    this.lastCheckOut,
    this.lastLatitude,
    this.lastLongitude,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor';
  bool get isEmployee => role == 'employee';

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'supervisor':
        return 'Supervisor';
      default:
        return 'Employee';
    }
  }

  Employee copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? designation,
    String? department,
    String? branchId,
    String? branchName,
    String? role,
    bool? isActive,
    DateTime? joinDate,
    String? address,
    String? emergencyContact,
    String? emergencyName,
    bool? isCheckedIn,
    DateTime? lastCheckIn,
    DateTime? lastCheckOut,
    double? lastLatitude,
    double? lastLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      joinDate: joinDate ?? this.joinDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyName: emergencyName ?? this.emergencyName,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      lastCheckOut: lastCheckOut ?? this.lastCheckOut,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);
}
