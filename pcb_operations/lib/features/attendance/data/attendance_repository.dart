import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/attendance.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collection = 'attendance';

  AttendanceRepository(this._firestore, this._auth);

  String get uid => _auth.currentUser?.uid ?? '';
  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get now => DateFormat('HH:mm').format(DateTime.now());

  Future<Attendance?> getTodayAttendance() {
    return _firestore
        .collection(_collection)
        .where('employeeId', isEqualTo: uid)
        .where('date', isEqualTo: today)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Attendance.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<Attendance> checkIn({
    required String employeeName,
    required String branchId,
    required double latitude,
    required double longitude,
    String? address,
    String? selfieBase64,
  }) async {
    final docId = '${uid}_$today';
    final lateCutoff = '09:15';
    final isLate = now.compareTo(lateCutoff) > 0;

    final attendance = Attendance(
      id: docId, employeeId: uid, employeeName: employeeName,
      branchId: branchId, date: today,
      checkInTime: now, checkInLatitude: latitude, checkInLongitude: longitude,
      checkInAddress: address, selfieUrl: selfieBase64,
      status: isLate ? 'late' : 'present',
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(docId).set(attendance.toJson());
    return attendance;
  }

  Future<Attendance> checkOut({
    required String docId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final update = {
      'checkOutTime': now,
      'checkOutLatitude': latitude,
      'checkOutLongitude': longitude,
      'checkOutAddress': address,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection(_collection).doc(docId).update(update);
    final snapshot = await _firestore.collection(_collection).doc(docId).get();
    return Attendance.fromJson(snapshot.data()! as Map<String, dynamic>);
  }

  Future<List<Attendance>> getAttendanceHistory({int days = 30}) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    return _firestore
        .collection(_collection)
        .where('employeeId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: startStr)
        .orderBy('date', descending: true)
        .get()
        .then((snapshot) =>
            snapshot.docs.map((doc) => Attendance.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<List<Attendance>> getBranchAttendance(String branchId, String date) {
    return _firestore
        .collection(_collection)
        .where('branchId', isEqualTo: branchId)
        .where('date', isEqualTo: date)
        .get()
        .then((snapshot) =>
            snapshot.docs.map((doc) => Attendance.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Attendance>> watchBranchAttendance(String branchId, String date) {
    return _firestore
        .collection(_collection)
        .where('branchId', isEqualTo: branchId)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Attendance.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<Attendance?> watchTodayAttendance() {
    return _firestore
        .collection(_collection)
        .where('employeeId', isEqualTo: uid)
        .where('date', isEqualTo: today)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Attendance.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    });
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final todayAttendanceProvider = StreamProvider.autoDispose<Attendance?>((ref) {
  return ref.watch(attendanceRepositoryProvider).watchTodayAttendance();
});

final attendanceHistoryProvider = FutureProvider.autoDispose<List<Attendance>>((ref) {
  return ref.watch(attendanceRepositoryProvider).getAttendanceHistory();
});

final branchAttendanceProvider = FutureProvider.autoDispose.family<List<Attendance>, DateAndBranch>((ref, params) {
  return ref.watch(attendanceRepositoryProvider)
      .getBranchAttendance(params.branchId, params.date);
});

class DateAndBranch {
  final String branchId, date;
  const DateAndBranch(this.branchId, this.date);
  @override
  bool operator ==(Object other) => other is DateAndBranch && other.branchId == branchId && other.date == date;
  @override
  int get hashCode => branchId.hashCode ^ date.hashCode;
}
