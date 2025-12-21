import 'package:cloud_firestore/cloud_firestore.dart';
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
    switch ((icon_string ?? " ").toLowerCase()) {
      default:
        return Icons.article;
    }
  }
}

class ResourcesRepository {
  final FirebaseFirestore Resourcedatabase;

  ResourcesRepository({FirebaseFirestore? resourcedatabase})
    : Resourcedatabase = resourcedatabase ?? FirebaseFirestore.instance;

  Stream<List<AppResource>> Featuredresources({int max = 2}) =>
      searchResources(max: max);
  Stream<List<AppResource>> Allresources() => searchResources();

  Stream<List<AppResource>> searchResources({int? max}) {
    Query<Map<String, dynamic>> Search = Resourcedatabase.collection(
      "Resources",
    ).orderBy('order');

    if (max != null) {
      Search = Search.limit(max);
    }

    return Search.snapshots().map(
      (snap) => snap.docs
          .map(
            (doc) => AppResource.fromDoc(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList(),
    );
  }
}
