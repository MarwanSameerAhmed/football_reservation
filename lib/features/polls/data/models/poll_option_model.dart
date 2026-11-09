import '../../domain/entities/poll_option_entity.dart';

class PollOptionModel extends PollOptionEntity {
  const PollOptionModel({
    required super.id,
    required super.text,
    super.subtitle,
    super.voterUserIds,
    super.metadata,
  });

  factory PollOptionModel.fromEntity(PollOptionEntity entity) {
    return PollOptionModel(
      id: entity.id,
      text: entity.text,
      subtitle: entity.subtitle,
      voterUserIds: List.from(entity.voterUserIds),
      metadata: entity.metadata != null ? Map.from(entity.metadata!) : null,
    );
  }

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      voterUserIds:
          (json['voterUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (subtitle != null) 'subtitle': subtitle,
      'voterUserIds': voterUserIds,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
