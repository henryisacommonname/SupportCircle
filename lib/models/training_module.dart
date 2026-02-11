import 'package:cloud_firestore/cloud_firestore.dart';

enum ModuleStatus { notStarted, inProgress, completed }

ModuleStatus statusFromString(String? value) {
  switch (value) {
    case 'inProgress':
      return ModuleStatus.inProgress;
    case 'completed':
      return ModuleStatus.completed;
    default:
      return ModuleStatus.notStarted;
  }
}

String statusToString(ModuleStatus status) {
  switch (status) {
    case ModuleStatus.inProgress:
      return 'inProgress';
    case ModuleStatus.completed:
      return 'completed';
    default:
      return 'notStarted';
  }
}

class TrainingModule {
  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final int order;
  final ModuleStatus status;
  final String? contentType;
  final String? contentURL;
  final String? youtubeURL;
  final String? body;
  final String? imageURL;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.order,
    this.status = ModuleStatus.notStarted,
    this.contentType,
    this.contentURL,
    this.youtubeURL,
    this.body,
    this.imageURL,
  });

  bool get hasImage => (imageURL ?? '').trim().isNotEmpty;

  bool get hasDisplayContent {
    final hasTitle = title.trim().isNotEmpty;
    final hasSubtitle = subtitle.trim().isNotEmpty;
    final hasBody = (body ?? '').trim().isNotEmpty;
    final hasVideo =
        (contentURL ?? '').trim().isNotEmpty ||
        (youtubeURL ?? '').trim().isNotEmpty;
    final hasPlaceholderCopy =
        _containsPlaceholderText(title) ||
        _containsPlaceholderText(subtitle) ||
        _containsPlaceholderText(body ?? '');
    return hasTitle &&
        (hasSubtitle || hasBody || hasVideo) &&
        !hasPlaceholderCopy;
  }

  static final RegExp _placeholderPattern = RegExp(
    r'(^\s*title for)|(^\s*subtitle for)|\b(test|placeholder|lorem|ipsum|dummy|tbd)\b',
    caseSensitive: false,
  );

  static bool _containsPlaceholderText(String value) =>
      _placeholderPattern.hasMatch(value.trim());

  TrainingModule copyWith({ModuleStatus? status, String? youtubeURL}) =>
      TrainingModule(
        id: id,
        title: title,
        subtitle: subtitle,
        minutes: minutes,
        order: order,
        status: status ?? this.status,
        contentType: contentType,
        contentURL: contentURL,
        youtubeURL: youtubeURL ?? this.youtubeURL,
        body: body,
        imageURL: imageURL,
      );

  factory TrainingModule.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final title = (data['title'] as String?)?.trim() ?? '';
    return TrainingModule(
      id: doc.id,
      title: title,
      subtitle: (data['subtitle'] as String?)?.trim() ?? '',
      imageURL: _resolveImage(data['imageURL'] as String?),
      minutes: (data['minutes'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
      contentType: data['contentType'] as String?,
      contentURL: data['contentURL'] as String?,
      youtubeURL: data['youtubeURL'] as String?,
      body: data['body'] as String?,
    );
  }

  static String? _resolveImage(String? url) {
    final trimmed = url?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
