import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppResource {
  final String id;
  final String title;
  final String subtitle;
  final String? youtubeURL;
  final String? body;
  final IconData icon;

  const AppResource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.youtubeURL,
    this.body,
  });

  factory AppResource.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppResource(
      id: doc.id,
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String)
          : 'Untitled resource',
      subtitle: data['subtitle'] as String? ?? '',
      youtubeURL: data['youtubeURL'] as String?,
      body: data['body'] as String?,
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
        return Icons.article_outlined;
    }
  }
}
