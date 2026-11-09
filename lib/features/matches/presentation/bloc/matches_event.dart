import 'package:equatable/equatable.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/player_position.dart';
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

  const CancelRegistrationRequested({
    required this.matchId,
    required this.playerId,
  });

  @override
  List<Object?> get props => [matchId, playerId];
}

class RecordMatchResultRequested extends MatchesEvent {
  final MatchResultEntity result;

  const RecordMatchResultRequested(this.result);

  @override
  List<Object?> get props => [result];
}
