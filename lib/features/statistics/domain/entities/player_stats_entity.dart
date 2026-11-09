import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';

/// Pure domain entity representing aggregated performance metrics for a player.
class PlayerStatsEntity extends Equatable {
  final String playerId;
  final String playerName;
  final String? photoUrl;
  final PlayerPosition position;
  final int matchesPlayed;
  final int goals;
  final int assists;
  final int cleanSheets;
  final int motmAwards;
  final int wins;
  final int draws;
  final int losses;

  const PlayerStatsEntity({
    required this.playerId,
    required this.playerName,
    this.photoUrl,
    required this.position,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.cleanSheets = 0,
    this.motmAwards = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  /// Win percentage on a scale of 0.0% to 100.0%.
  double get winRate {
    if (matchesPlayed == 0) return 0.0;
    final rate = (wins / matchesPlayed) * 100;
    return (rate * 10).round() / 10;
  }

  /// Total direct goal contributions (Goals + Assists).
  int get goalContributions => goals + assists;

  /// Average goals scored per match.
  double get goalsPerMatch {
    if (matchesPlayed == 0) return 0.0;
    final rate = goals / matchesPlayed;
    return (rate * 10).round() / 10;
  }

  PlayerStatsEntity copyWith({
    String? playerId,
    String? playerName,
    String? photoUrl,
    PlayerPosition? position,
    int? matchesPlayed,
    int? goals,
    int? assists,
    int? cleanSheets,
    int? motmAwards,
    int? wins,
    int? draws,
    int? losses,
  }) {
    return PlayerStatsEntity(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      photoUrl: photoUrl ?? this.photoUrl,
      position: position ?? this.position,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      cleanSheets: cleanSheets ?? this.cleanSheets,
      motmAwards: motmAwards ?? this.motmAwards,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
    );
  }

  @override
  List<Object?> get props => [
    playerId,
    playerName,
    photoUrl,
    position,
    matchesPlayed,
    goals,
    assists,
    cleanSheets,
    motmAwards,
    wins,
    draws,
    losses,
  ];
}
