import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/poll_type.dart';
import '../../domain/entities/poll_entity.dart';
import 'poll_option_model.dart';

class PollModel extends PollEntity {
  const PollModel({
    required super.id,
    super.matchId,
    required super.title,
    super.description,
    required super.type,
    required super.options,
    required super.creatorId,
    super.allowMultipleVotes,
    required super.closesAt,
    super.isClosed,
    required super.createdAt,
  });

  factory PollModel.fromEntity(PollEntity entity) {
    return PollModel(
      id: entity.id,
      matchId: entity.matchId,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      options: entity.options
          .map((o) => PollOptionModel.fromEntity(o))
          .toList(),
      creatorId: entity.creatorId,
      allowMultipleVotes: entity.allowMultipleVotes,
      closesAt: entity.closesAt,
      isClosed: entity.isClosed,
      createdAt: entity.createdAt,
    );
  }

  factory PollModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final rawType = json['type'] as String? ?? 'general';
    final pollType = PollType.values.firstWhere(
      (t) => t.name == rawType,
      orElse: () => PollType.general,
    );

    final rawClosesAt = json['closesAt'];
    final closesAt = rawClosesAt is Timestamp
        ? rawClosesAt.toDate()
        : DateTime.tryParse(rawClosesAt?.toString() ?? '') ??
              DateTime.now().add(const Duration(days: 2));

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is Timestamp
        ? rawCreatedAt.toDate()
        : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();

    final optionsJson = (json['options'] as List<dynamic>?) ?? [];
    final options = optionsJson
        .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PollModel(
      id: docId ?? (json['id'] as String? ?? ''),
      matchId: json['matchId'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: pollType,
      options: options,
      creatorId: json['creatorId'] as String? ?? '',
      allowMultipleVotes: json['allowMultipleVotes'] as bool? ?? false,
      closesAt: closesAt,
      isClosed: json['isClosed'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  factory PollModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PollModel.fromJson(doc.data() ?? {}, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (matchId != null) 'matchId': matchId,
      'title': title,
      if (description != null) 'description': description,
      'type': type.name,
      'options': options
          .map((o) => PollOptionModel.fromEntity(o).toJson())
          .toList(),
      'creatorId': creatorId,
      'allowMultipleVotes': allowMultipleVotes,
      'closesAt': Timestamp.fromDate(closesAt),
      'isClosed': isClosed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
