import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/leave.dart';

class LeaveRepository {
  final FirebaseFirestore _firestore;
  static const _col = 'leaves';

  LeaveRepository(this._firestore);

  Future<void> submitLeaveRequest(LeaveRequest leave) {
    return _firestore.collection(_col).doc(leave.id).set(leave.toJson());
  }

  Stream<List<LeaveRequest>> watchEmployeeLeaves(String employeeId) {
    return _firestore.collection(_col)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LeaveRequest.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<LeaveRequest>> watchPendingLeaves(String branchId) {
    return _firestore.collection(_col)
        .where('branchId', isEqualTo: branchId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map((d) => LeaveRequest.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> approveLeave(String leaveId, String adminId, String remarks) {
    return _firestore.collection(_col).doc(leaveId).update({
      'status': 'approved', 'adminId': adminId,
      'adminRemarks': remarks, 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectLeave(String leaveId, String adminId, String remarks) {
    return _firestore.collection(_col).doc(leaveId).update({
      'status': 'rejected', 'adminId': adminId,
      'adminRemarks': remarks, 'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(FirebaseFirestore.instance);
});

final employeeLeavesProvider = StreamProvider.autoDispose.family<List<LeaveRequest>, String>((ref, empId) {
  return ref.watch(leaveRepositoryProvider).watchEmployeeLeaves(empId);
});
