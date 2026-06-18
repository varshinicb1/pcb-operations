import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/bus.dart';

class ProductionRepository {
  final FirebaseFirestore _firestore;
  static const _col = 'buses';
  static const _updatesCol = 'production_updates';

  ProductionRepository(this._firestore);

  Stream<List<Bus>> watchAllBuses({String? branchId}) {
    Query q = _firestore.collection(_col).orderBy('createdAt', descending: true);
    if (branchId != null) q = q.where('branchId', isEqualTo: branchId);
    return q.snapshots().map((s) => s.docs.map((d) => Bus.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updateBusStage(String busId, int stageIdx, String stage, String userId, String userName, {String? photoBase64, String? remarks}) async {
    await _firestore.collection(_col).doc(busId).update({
      'currentStage': stage, 'currentStageIndex': stageIdx,
      'lastUpdatedBy': userId, 'lastUpdatedByName': userName,
      'lastRemarks': remarks, 'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection(_updatesCol).add({
      'busId': busId, 'stage': stage, 'stageIndex': stageIdx,
      'photoBase64': photoBase64, 'remarks': remarks,
      'updatedBy': userId, 'updatedByName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ProductionUpdate>> watchUpdates(String busId) {
    return _firestore.collection(_updatesCol)
        .where('busId', isEqualTo: busId).orderBy('createdAt', descending: true)
        .snapshots().map((s) => s.docs.map((d) => ProductionUpdate.fromJson(d.data() as Map<String, dynamic>)).toList());
  }
}

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  return ProductionRepository(FirebaseFirestore.instance);
});

final allBusesProvider = StreamProvider.autoDispose.family<List<Bus>, String?>((ref, branchId) {
  return ref.watch(productionRepositoryProvider).watchAllBuses(branchId: branchId);
});
