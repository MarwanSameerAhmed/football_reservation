import 'package:equatable/equatable.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../domain/entities/team_lineup_entity.dart';

abstract class TeamGeneratorEvent extends Equatable {
  const TeamGeneratorEvent();

  @override
  List<Object?> get props => [];
}

class GenerateBalancedTeamsRequested extends TeamGeneratorEvent {
  final String matchId;
  final List<PlayerEntity> players;

  const GenerateBalancedTeamsRequested({
    required this.matchId,
    required this.players,
  });

  @override
  List<Object?> get props => [matchId, players];
}

class SwapPlayersRequested extends TeamGeneratorEvent {
  final TeamLineupEntity lineup;
  final String playerAId;
  final String playerBId;

  const SwapPlayersRequested({
    required this.lineup,
    required this.playerAId,
    required this.playerBId,
  });

  @override
  List<Object?> get props => [lineup, playerAId, playerBId];
}

class SelectPlayerForSwapRequested extends TeamGeneratorEvent {
  final PlayerEntity player;

  const SelectPlayerForSwapRequested(this.player);

  @override
  List<Object?> get props => [player];
}

class ClearSwapSelectionRequested extends TeamGeneratorEvent {
  const ClearSwapSelectionRequested();
}

class SaveFinalLineupRequested extends TeamGeneratorEvent {
  final TeamLineupEntity lineup;

  const SaveFinalLineupRequested(this.lineup);

  @override
  List<Object?> get props => [lineup];
}

class LoadLineupHistoryRequested extends TeamGeneratorEvent {
  final String? matchId;

  const LoadLineupHistoryRequested({this.matchId});

  @override
  List<Object?> get props => [matchId];
}
