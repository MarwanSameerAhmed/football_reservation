import 'package:equatable/equatable.dart';
import '../../../../core/enums/poll_type.dart';
import 'poll_option_entity.dart';

/// Pure domain entity representing an interactive group poll.
class PollEntity extends Equatable {
  final String id;
  final String? matchId;
  final String? matchDetails;
  final String title;
  final String? description;
  final PollType type;
  final List<PollOptionEntity> options;
  final String creatorId;
  final bool allowMultipleVotes;
  final DateTime closesAt;
  final bool isClosed;
  final bool isLockedUntilMatchEnds;
  final DateTime createdAt;

  const PollEntity({
    required this.id,
    this.matchId,
    this.matchDetails,
    required this.title,
    this.description,
    required this.type,
    required this.options,
    required this.creatorId,
    this.allowMultipleVotes = false,
    required this.closesAt,
    this.isClosed = false,
    this.isLockedUntilMatchEnds = false,
    required this.createdAt,
  });

  /// Total sum of all votes cast across all options.
  int get totalVotes => options.fold(0, (sum, o) => sum + o.voteCount);

  /// Whether the deadline has passed.
  bool get hasExpired => DateTime.now().isAfter(closesAt);

  /// A poll is active if not manually closed, deadline has not elapsed, and not locked waiting for match completion.
  bool get isActive => !isClosed && !hasExpired && !isLockedUntilMatchEnds;

  /// Check if a user has cast at least one vote in this poll.
  bool hasUserVoted(String userId) => options.any((o) => o.hasVoted(userId));

  /// Finds the option ID chosen by the user (if any).
  String? getUserVotedOptionId(String userId) {
    for (final opt in options) {
      if (opt.hasVoted(userId)) return opt.id;
    }
    return null;
  }

  /// Calculates the percentage of total votes for a specific option (0.0 to 100.0).
  double optionPercentage(PollOptionEntity option) {
    if (totalVotes == 0) return 0.0;
    final pct = (option.voteCount / totalVotes) * 100;
    return (pct * 10).round() / 10;
  }

  /// Determines the option currently holding the highest votes.
  PollOptionEntity? get winningOption {
    if (options.isEmpty || totalVotes == 0) return null;
    PollOptionEntity top = options.first;
    for (final opt in options) {
      if (opt.voteCount > top.voteCount) {
        top = opt;
      }
    }
    return top;
  }

  PollEntity copyWith({
    String? id,
    String? matchId,
    String? matchDetails,
    String? title,
    String? description,
    PollType? type,
    List<PollOptionEntity>? options,
    String? creatorId,
    bool? allowMultipleVotes,
    DateTime? closesAt,
    bool? isClosed,
    bool? isLockedUntilMatchEnds,
    DateTime? createdAt,
  }) {
    return PollEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      matchDetails: matchDetails ?? this.matchDetails,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      options: options ?? this.options,
      creatorId: creatorId ?? this.creatorId,
      allowMultipleVotes: allowMultipleVotes ?? this.allowMultipleVotes,
      closesAt: closesAt ?? this.closesAt,
      isClosed: isClosed ?? this.isClosed,
      isLockedUntilMatchEnds:
          isLockedUntilMatchEnds ?? this.isLockedUntilMatchEnds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    matchId,
    matchDetails,
    title,
    description,
    type,
    options,
    creatorId,
    allowMultipleVotes,
    closesAt,
    isClosed,
    isLockedUntilMatchEnds,
    createdAt,
  ];
}
