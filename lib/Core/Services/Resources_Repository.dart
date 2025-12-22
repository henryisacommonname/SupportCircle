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
      icon: iconFromName(data['icon'] as String?),
    );
  }

  static IconData iconFromName(String? icon_string) {
    switch ((icon_string ?? '').toLowerCase()) {
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
        return Icons.article_outlined;
    }
  }
}

class ResourcesRepository {
  final FirebaseFirestore _firestore;

  ResourcesRepository({FirebaseFirestore? resourcedatabase})
    : _firestore = resourcedatabase ?? FirebaseFirestore.instance;

  Stream<List<AppResource>> Featuredresources({int max = 2}) =>
      searchResources(max: max);
  Stream<List<AppResource>> Allresources() => searchResources();

  Stream<List<AppResource>> searchResources({int? max}) {
    Query<Map<String, dynamic>> query = _firestore.collection("Resources");

    if (max != null) {
      query = query.limit(max);
    }

    if (kDebugMode) {
      debugPrint(
        '[Resources] subscribe collection=Resources limit=${max ?? 'none'}',
      );
    }

    return query
        .snapshots(includeMetadataChanges: kDebugMode)
        .map((snap) {
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
        })
        .handleError((error) {
          if (kDebugMode) {
            debugPrint('[Resources] stream error: $error');
          }
        });
  }
}
