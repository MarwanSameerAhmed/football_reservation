import 'package:equatable/equatable.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_result_entity.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatchesRequested extends MatchesEvent {
  final MatchStatus? statusFilter;
  const LoadMatchesRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class SelectMatchRequested extends MatchesEvent {
  final String matchId;
  const SelectMatchRequested(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class RegisterPlayerRequested extends MatchesEvent {
  final String matchId;
  final String playerId;
  final String playerName;
  final PlayerPosition position;

  const RegisterPlayerRequested({
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.position,
  });

  @override
  List<Object?> get props => [matchId, playerId, playerName, position];
}

class CancelRegistrationRequested extends MatchesEvent {
  final String matchId;
  final String playerId;
  final String? playerName;
  final String? reason;
  final String? customNote;

  const CancelRegistrationRequested({
    required this.matchId,
    required this.playerId,
    this.playerName,
    this.reason,
    this.customNote,
  });

  @override
  List<Object?> get props => [matchId, playerId, playerName, reason, customNote];
}

class RecordMatchResultRequested extends MatchesEvent {
  final MatchResultEntity result;

  const RecordMatchResultRequested(this.result);

  @override
  List<Object?> get props => [result];
}

class CreateMatchRequested extends MatchesEvent {
  final MatchEntity match;

  const CreateMatchRequested(this.match);

  @override
  List<Object?> get props => [match];
}

/// Admin action: Manually promote a waiting list player to confirmed squad.
class PromotePlayerToConfirmedRequested extends MatchesEvent {
  final String matchId;
  final String playerId;

  const PromotePlayerToConfirmedRequested({
    required this.matchId,
    required this.playerId,
  });

  @override
  List<Object?> get props => [matchId, playerId];
}

/// Admin action: Manually demote a confirmed player to waiting list.
class DemotePlayerToWaitlistRequested extends MatchesEvent {
  final String matchId;
  final String playerId;

  const DemotePlayerToWaitlistRequested({
    required this.matchId,
    required this.playerId,
  });

  @override
  List<Object?> get props => [matchId, playerId];
}
