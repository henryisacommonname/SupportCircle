import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppResource {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const AppResource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  factory AppResource.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppResource(
      id: doc.id,
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String)
          : 'Untitled resource',
      subtitle: data['subtitle'] as String? ?? '',
      icon: _iconFromName(data['icon'] as String?),
    );
  }

  static IconData _iconFromName(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'book':
      case 'menu_book':
      case 'menu_book_outlined':
        return Icons.menu_book_outlined;
      case 'school':
      case 'school_outlined':
        return Icons.school_outlined;
      case 'call':
      case 'phone':
        return Icons.call;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class ResourceRepository {
  final FirebaseFirestore _firestore;
  ResourceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<AppResource>> featuredResources({int limit = 3}) =>
      _queryResources(limit: limit);

  Stream<List<AppResource>> allResources() => _queryResources();

  Stream<List<AppResource>> _queryResources({int? limit}) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('resources').orderBy('order');
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots(includeMetadataChanges: kDebugMode).map((snap) {
      if (kDebugMode) {
        debugPrint(
          '[Resources] count=${snap.docs.length} cache=${snap.metadata.isFromCache}',
        );
      }
      return snap.docs
          .map(
            (doc) => AppResource.fromDoc(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    }).handleError((error) {
      if (kDebugMode) {
        debugPrint('[Resources] stream error: $error');
      }
    });
  }
}
