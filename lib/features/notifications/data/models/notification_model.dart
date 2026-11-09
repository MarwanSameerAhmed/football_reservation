import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/notification_type.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.targetId,
    super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      targetId: entity.targetId,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  @override
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? targetId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    final rawType = json['type'] as String? ?? 'matchAnnouncement';
    final type = NotificationType.values.firstWhere(
      (t) => t.name == rawType,
      orElse: () => NotificationType.matchAnnouncement,
    );

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is Timestamp
        ? rawCreatedAt.toDate()
        : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();

    return NotificationModel(
      id: docId ?? (json['id'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: type,
      targetId: json['targetId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return NotificationModel.fromJson(doc.data() ?? {}, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      if (targetId != null) 'targetId': targetId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
