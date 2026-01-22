import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_log.dart';

class ServiceLogRepository {
  final FirebaseFirestore _firestore;

  ServiceLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _logsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('ServiceLogs');

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  Stream<List<ServiceLog>> serviceLogs(String userId) => _logsCollection(userId)
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => ServiceLog.fromDoc(d))
            .toList(),
      );

  Stream<double> totalHours(String userId) => _userDoc(userId)
      .snapshots()
      .map((snap) => (snap.data()?['TimeTracker'] as num?)?.toDouble() ?? 0.0);

  Future<void> addLog({
    required String userId,
    required DateTime date,
    required double hours,
    required String description,
  }) async {
    final batch = _firestore.batch();

    final newLogRef = _logsCollection(userId).doc();
    batch.set(newLogRef, {
      'date': Timestamp.fromDate(date),
      'hours': hours,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_userDoc(userId), {
      'TimeTracker': FieldValue.increment(hours),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> deleteLog({
    required String userId,
    required String logId,
    required double hours,
  }) async {
    final batch = _firestore.batch();

    batch.delete(_logsCollection(userId).doc(logId));

    batch.update(_userDoc(userId), {
      'TimeTracker': FieldValue.increment(-hours),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
