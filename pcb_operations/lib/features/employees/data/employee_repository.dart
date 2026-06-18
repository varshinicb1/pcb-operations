import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee.dart';

class EmployeeRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'employees';

  EmployeeRepository(this._firestore);

  Future<List<Employee>> getAllEmployees({String? branchId}) {
    Query query = _firestore.collection(_collection).where('isActive', isEqualTo: true);
    if (branchId != null) {
      query = query.where('branchId', isEqualTo: branchId);
    }
    return query.get().then((snapshot) =>
        snapshot.docs.map((doc) => Employee.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<Employee?> getEmployee(String id) {
    return _firestore.collection(_collection).doc(id).get().then(
        (doc) => doc.exists ? Employee.fromJson(doc.data()!) : null);
  }

  Future<Employee?> getEmployeeByEmployeeId(String employeeId) {
    return _firestore
        .collection(_collection)
        .where('employeeId', isEqualTo: employeeId)
        .limit(1)
        .get()
        .then((snapshot) =>
            snapshot.docs.isNotEmpty
                ? Employee.fromJson(snapshot.docs.first.data())
                : null);
  }

  Future<List<Employee>> searchEmployees(String query, {String? branchId}) {
    final searchLower = query.toLowerCase();
    return getAllEmployees(branchId: branchId).then((employees) =>
        employees.where((e) =>
            e.name.toLowerCase().contains(searchLower) ||
            e.employeeId.toLowerCase().contains(searchLower) ||
            e.designation.toLowerCase().contains(searchLower) ||
            e.department.toLowerCase().contains(searchLower) ||
            e.phone.contains(query)).toList());
  }

  Future<List<Employee>> getEmployeesByDepartment(String department, {String? branchId}) {
    Query query = _firestore
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('isActive', isEqualTo: true);
    if (branchId != null) {
      query = query.where('branchId', isEqualTo: branchId);
    }
    return query.get().then((snapshot) =>
        snapshot.docs.map((doc) => Employee.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Employee>> watchAllEmployees({String? branchId}) {
    Query query = _firestore.collection(_collection).where('isActive', isEqualTo: true);
    if (branchId != null) {
      query = query.where('branchId', isEqualTo: branchId);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Employee.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updateEmployee(Employee employee) {
    return _firestore
        .collection(_collection)
        .doc(employee.id)
        .update(employee.copyWith(updatedAt: DateTime.now()).toJson());
  }
}

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(FirebaseFirestore.instance);
});

final allEmployeesProvider = FutureProvider.autoDispose.family<List<Employee>, String?>((ref, branchId) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getAllEmployees(branchId: branchId);
});

final employeesStreamProvider = StreamProvider.autoDispose.family<List<Employee>, String?>((ref, branchId) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.watchAllEmployees(branchId: branchId);
});
