import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee.dart';

class EmployeeProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EmployeeProfileRepository(this._firestore, this._auth);

  Future<Employee?> fetchCurrentEmployee() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('employees').doc(uid).get();
    if (!doc.exists) return null;
    return Employee.fromJson(doc.data()!);
  }

  Stream<Employee?> watchCurrentEmployee() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _firestore.collection('employees').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Employee.fromJson(doc.data()!);
    });
  }
}

final employeeProfileRepoProvider = Provider<EmployeeProfileRepository>((ref) {
  return EmployeeProfileRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final currentEmployeeProvider = StreamProvider.autoDispose<Employee?>((ref) {
  return ref.watch(employeeProfileRepoProvider).watchCurrentEmployee();
});

final currentEmployeeRoleProvider = Provider<String>((ref) {
  return ref.watch(currentEmployeeProvider).valueOrNull?.role ?? 'employee';
});

final currentEmployeeBranchProvider = Provider<String>((ref) {
  return ref.watch(currentEmployeeProvider).valueOrNull?.branchId ?? 'default';
});
