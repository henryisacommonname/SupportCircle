import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum ModuleStatus { notStarted, inProgress, completed }

ModuleStatus StringtoStatus(String? S) {
  switch (S) {
    case "inProgress":
      return ModuleStatus.inProgress;
    case "completed":
      return ModuleStatus.completed;
    default:
      return ModuleStatus.notStarted;
  }
}

String StatustoString(ModuleStatus MS) {
  switch (MS) {
    case ModuleStatus.inProgress:
      return "inProgress";
    case ModuleStatus.completed:
      return "completed";
    default:
      return "notStarted";
  }
}

class TrainingModule {
  final String? contentType;
  final String? contentURL;
  final String? body;
  final String id;
  final String title;
  final String subtitle;
  final String? imageURL;
  final int minutes;
  final int order;
  final ModuleStatus status;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.order,
    this.status = ModuleStatus.notStarted,
    this.contentType,
    this.contentURL,
    this.body,
    this.imageURL,
  });

  bool get hasimage => (imageURL ?? '').trim().isNotEmpty;

  TrainingModule copyWith({ModuleStatus? status}) => TrainingModule(
    contentType: contentType,
    contentURL: contentURL,
    body: body,
    id: id,
    title: title,
    subtitle: subtitle,
    imageURL: imageURL,
    minutes: minutes,
    order: order,
    status: status ?? this.status,
  );

  factory TrainingModule.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final D = doc.data()!;
    return TrainingModule(
      id: doc.id,
      title: D['title'] as String,
      subtitle: D['subtitle'] as String,
      imageURL: ResolveImage(D['imageURL'] as String?),
      minutes: (D['minutes'] as num).toInt(),
      order: (D['order'] as num?)?.toInt() ?? 0,
      contentType: D['contentType'] as String?,
      contentURL: D['contentURL'] as String?,
      body: D['body'] as String?,
    );
  }
  static String? ResolveImage(String? URL) {
    final trimmed = URL?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

class TrainingRepository {
  final FirebaseFirestore _f;

  TrainingRepository({FirebaseFirestore? f})
    : _f = f ?? FirebaseFirestore.instance;
  Stream<List<TrainingModule>> _modules() => _f
      .collection("TrainingModules")
      .orderBy("order")
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
  //combine stream here
  Stream<Map<String, ModuleStatus>> _Progress(String UserID) => _f
      .collection('users')
      .doc(UserID)
      .collection('ModuleProgress')
      .snapshots()
      .map(
        (snap) => {
          for (final D in snap.docs)
            D.id: StringtoStatus(D.data()["status"] as String),
        },
      );
  Stream<List<TrainingModule>> ModuleswithStatus(String UserID) =>
      Rx.combineLatest2(
        _modules(),
        _Progress(UserID),
        (List<TrainingModule> mods, Map<String, ModuleStatus> prog) =>
            mods.map((m) => m.copyWith(status: prog[m.id])).toList(),
      );

  Future<void> setStatus({
    required String uid,
    required String moduleid,
    required ModuleStatus status,
  }) async {
    await _f
        .collection("users")
        .doc(uid)
        .collection("ModuleProgress")
        .doc(moduleid)
        .set({
          "status": StatustoString(status),
          "UpdatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
