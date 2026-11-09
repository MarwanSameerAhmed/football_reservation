import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single choice/option within a poll.
class PollOptionEntity extends Equatable {
  final String id;
  final String text;
  final String? subtitle;
  final List<String> voterUserIds;
  final Map<String, dynamic>? metadata;

  const PollOptionEntity({
    required this.id,
    required this.text,
    this.subtitle,
    this.voterUserIds = const [],
    this.metadata,
  });

  int get voteCount => voterUserIds.length;

  bool hasVoted(String userId) => voterUserIds.contains(userId);

  PollOptionEntity copyWith({
    String? id,
    String? text,
    String? subtitle,
    List<String>? voterUserIds,
    Map<String, dynamic>? metadata,
  }) {
    return PollOptionEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      subtitle: subtitle ?? this.subtitle,
      voterUserIds: voterUserIds ?? this.voterUserIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, text, subtitle, voterUserIds, metadata];
}
