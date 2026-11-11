import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/preferred_foot.dart';
import 'player_skills.dart';

/// Pure domain entity representing a football player profile in Kickoff.
class PlayerEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? nickname;
  final String? photoUrl;
  final PlayerPosition primaryPosition;
  final PlayerPosition? secondaryPosition;
  final PreferredFoot preferredFoot;
  final int? jerseyNumber;
  final PlayerSkills skills;
  final int matchesPlayed;
  final int goals;
  final int assists;
  final int motmCount;
  final bool isAvailable;
  final DateTime createdAt;

  const PlayerEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.nickname,
    this.photoUrl,
    required this.primaryPosition,
    this.secondaryPosition,
    this.preferredFoot = PreferredFoot.right,
    this.jerseyNumber,
    required this.skills,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.motmCount = 0,
    this.isAvailable = true,
    required this.createdAt,
  });

  double get rating => skills.starsRating;

  PlayerEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? nickname,
    String? photoUrl,
    PlayerPosition? primaryPosition,
    PlayerPosition? secondaryPosition,
    PreferredFoot? preferredFoot,
    int? jerseyNumber,
    PlayerSkills? skills,
    int? matchesPlayed,
    int? goals,
    int? assists,
    int? motmCount,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return PlayerEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      primaryPosition: primaryPosition ?? this.primaryPosition,
      secondaryPosition: secondaryPosition ?? this.secondaryPosition,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      skills: skills ?? this.skills,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      motmCount: motmCount ?? this.motmCount,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    nickname,
    photoUrl,
    primaryPosition,
    secondaryPosition,
    preferredFoot,
    jerseyNumber,
    skills,
    matchesPlayed,
    goals,
    assists,
    motmCount,
    isAvailable,
    createdAt,
  ];
}
