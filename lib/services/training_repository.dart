import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../models/training_module.dart';

class TrainingRepository {
  final FirebaseFirestore _firestore;

  TrainingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<TrainingModule>> _modules() => _firestore
      .collection('TrainingModules')
      .orderBy('order')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (s, _) => s.data() ?? {},
        toFirestore: (m, _) => m,
      )
      .snapshots()
      .map(
        (snap) => snap.docs
            .map(
              (d) => TrainingModule.fromDoc(
                d as DocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList(),
      );

  Stream<Map<String, ModuleStatus>> _progress(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('ModuleProgress')
      .snapshots()
      .map(
        (snap) => {
          for (final doc in snap.docs)
            doc.id: statusFromString(doc.data()['status'] as String),
        },
      );

  Stream<List<TrainingModule>> modulesWithStatus(String userId) =>
      Rx.combineLatest2(
        _modules(),
        _progress(userId),
        (List<TrainingModule> mods, Map<String, ModuleStatus> prog) =>
            mods.map((m) => m.copyWith(status: prog[m.id])).toList(),
      );

  Future<void> setStatus({
    required String uid,
    required String moduleId,
    required ModuleStatus status,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('ModuleProgress')
        .doc(moduleId)
        .set({
          'status': statusToString(status),
          'UpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
