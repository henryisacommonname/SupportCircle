import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/default_content.dart';
import '../models/app_resource.dart';

class ResourceRepository {
  final FirebaseFirestore _firestore;

  ResourceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<AppResource>> featuredResources({int limit = 3}) =>
      _queryResources(limit: limit);

  Stream<List<AppResource>> allResources() => _queryResources();

  Stream<List<AppResource>> _queryResources({int? limit}) {
    Query<Map<String, dynamic>> query = _firestore.collection('Resources');
    if (limit != null) {
      query = query.limit(limit);
    }

    if (kDebugMode) {
      debugPrint(
        '[Resources] subscribe collection=Resources limit=${limit ?? 'none'}',
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
          final resources = snap.docs
              .map(
                (doc) => AppResource.fromDoc(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .where((resource) => resource.hasDisplayContent)
              .toList();
          if (resources.length < 2) {
            if (limit == null) {
              return defaultResources;
            }
            return defaultResources.take(limit).toList();
          }
          return resources;
        })
        .handleError((error) {
          if (kDebugMode) {
            debugPrint('[Resources] stream error: $error');
          }
        });
  }
}
