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

  bool get hasDisplayContent {
    final hasTitle = title.trim().isNotEmpty;
    final hasBody = (body ?? '').trim().isNotEmpty;
    final hasVideo = (youtubeURL ?? '').trim().isNotEmpty;
    final hasPlaceholderCopy =
        _containsPlaceholderText(title) ||
        _containsPlaceholderText(subtitle) ||
        _containsPlaceholderText(body ?? '');
    return hasTitle && (hasBody || hasVideo) && !hasPlaceholderCopy;
  }

  static final RegExp _placeholderPattern = RegExp(
    r'(^\s*title for)|(^\s*subtitle for)|\b(test|placeholder|lorem|ipsum|dummy|tbd)\b',
    caseSensitive: false,
  );

  static bool _containsPlaceholderText(String value) =>
      _placeholderPattern.hasMatch(value.trim());

  factory AppResource.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final title = (data['title'] as String?)?.trim() ?? '';
    return AppResource(
      id: doc.id,
      title: title,
      subtitle: (data['subtitle'] as String?)?.trim() ?? '',
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
