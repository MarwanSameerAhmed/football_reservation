import 'package:equatable/equatable.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../domain/entities/team_lineup_entity.dart';

abstract class TeamGeneratorState extends Equatable {
  const TeamGeneratorState();

  @override
  List<Object?> get props => [];
}

class TeamGeneratorInitial extends TeamGeneratorState {
  const TeamGeneratorInitial();
}

class TeamGeneratorLoading extends TeamGeneratorState {
  final String? message;

  const TeamGeneratorLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class TeamGeneratorSuccess extends TeamGeneratorState {
  final TeamLineupEntity? currentLineup;
  final PlayerEntity? selectedPlayerForSwap;
  final bool isSaving;
  final List<TeamLineupEntity> history;
  final String? feedbackMessage;

  const TeamGeneratorSuccess({
    this.currentLineup,
    this.selectedPlayerForSwap,
    this.isSaving = false,
    this.history = const [],
    this.feedbackMessage,
  });

  TeamGeneratorSuccess copyWith({
    TeamLineupEntity? currentLineup,
    PlayerEntity? selectedPlayerForSwap,
    bool clearSelectedPlayer = false,
    bool? isSaving,
    List<TeamLineupEntity>? history,
    String? feedbackMessage,
  }) {
    return TeamGeneratorSuccess(
      currentLineup: currentLineup ?? this.currentLineup,
      selectedPlayerForSwap: clearSelectedPlayer
          ? null
          : (selectedPlayerForSwap ?? this.selectedPlayerForSwap),
      isSaving: isSaving ?? this.isSaving,
      history: history ?? this.history,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentLineup,
    selectedPlayerForSwap,
    isSaving,
    history,
    feedbackMessage,
  ];
}

class TeamGeneratorErrorState extends TeamGeneratorState {
  final String message;

  const TeamGeneratorErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
