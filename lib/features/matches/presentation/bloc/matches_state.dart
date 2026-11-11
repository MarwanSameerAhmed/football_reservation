import 'package:equatable/equatable.dart';
import '../../domain/entities/match_entity.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

class MatchesLoading extends MatchesState {
  const MatchesLoading();
}

class MatchesLoaded extends MatchesState {
  final List<MatchEntity> matches;
  final MatchEntity? selectedMatch;
  final String? successMessage;

  const MatchesLoaded({
    required this.matches,
    this.selectedMatch,
    this.successMessage,
  });

  MatchesLoaded copyWith({
    List<MatchEntity>? matches,
    MatchEntity? selectedMatch,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return MatchesLoaded(
      matches: matches ?? this.matches,
      selectedMatch: selectedMatch ?? this.selectedMatch,
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [matches, selectedMatch, successMessage];
}

class MatchesEmptyState extends MatchesState {
  final String message;
  const MatchesEmptyState([this.message = 'لا توجد مباريات مجدولة حالياً']);

  @override
  List<Object?> get props => [message];
}

class MatchesErrorState extends MatchesState {
  final String errorMessage;
  const MatchesErrorState(this.errorMessage);

  String get message => errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
