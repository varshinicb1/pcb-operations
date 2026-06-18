import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/daily_report.dart';

class ReportingRepository {
  final FirebaseFirestore _firestore;
  static const _col = 'daily_reports';

  ReportingRepository(this._firestore);

  Future<void> submitReport(DailyReport report) {
    return _firestore.collection(_col).doc(report.id).set(report.toJson());
  }

  Stream<List<DailyReport>> watchBranchReports(String branchId) {
    return _firestore.collection(_col)
        .where('branchId', isEqualTo: branchId).orderBy('date', descending: true).limit(20)
        .snapshots().map((s) => s.docs.map((d) => DailyReport.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<DailyReport>> watchTodayReports(String branchId) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _firestore.collection(_col)
        .where('branchId', isEqualTo: branchId).where('date', isEqualTo: today)
        .snapshots().map((s) => s.docs.map((d) => DailyReport.fromJson(d.data() as Map<String, dynamic>)).toList());
  }
}

final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  return ReportingRepository(FirebaseFirestore.instance);
});

final branchReportsProvider = StreamProvider.autoDispose.family<List<DailyReport>, String>((ref, branchId) {
  return ref.watch(reportingRepositoryProvider).watchBranchReports(branchId);
});

final todayReportsProvider = StreamProvider.autoDispose.family<List<DailyReport>, String>((ref, branchId) {
  return ref.watch(reportingRepositoryProvider).watchTodayReports(branchId);
});
