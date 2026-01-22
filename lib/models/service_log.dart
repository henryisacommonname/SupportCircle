import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceLog {
  final String id;
  final DateTime date;
  final double hours;
  final String description;
  final DateTime createdAt;

  const ServiceLog({
    required this.id,
    required this.date,
    required this.hours,
    required this.description,
    required this.createdAt,
  });

  factory ServiceLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ServiceLog(
      id: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hours: (data['hours'] as num?)?.toDouble() ?? 0.0,
      description: (data['description'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'hours': hours,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
