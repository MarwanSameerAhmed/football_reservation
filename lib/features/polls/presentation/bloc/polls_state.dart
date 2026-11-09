import 'package:equatable/equatable.dart';
import '../../domain/entities/poll_entity.dart';

abstract class PollsState extends Equatable {
  const PollsState();

  @override
  List<Object?> get props => [];
}

class PollsInitial extends PollsState {
  const PollsInitial();
}

class PollsLoading extends PollsState {
  final String? message;
  const PollsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class PollsEmptyState extends PollsState {
  const PollsEmptyState();
}

class PollsLoaded extends PollsState {
  final List<PollEntity> polls;
  final PollEntity? selectedPoll;
  final bool isVoting;
  final bool isCreating;
  final String? feedbackMessage;

  const PollsLoaded({
    required this.polls,
    this.selectedPoll,
    this.isVoting = false,
    this.isCreating = false,
    this.feedbackMessage,
  });

  PollsLoaded copyWith({
    List<PollEntity>? polls,
    PollEntity? selectedPoll,
    bool? isVoting,
    bool? isCreating,
    String? feedbackMessage,
    bool clearSelectedPoll = false,
  }) {
    return PollsLoaded(
      polls: polls ?? this.polls,
      selectedPoll: clearSelectedPoll
          ? null
          : (selectedPoll ?? this.selectedPoll),
      isVoting: isVoting ?? this.isVoting,
      isCreating: isCreating ?? this.isCreating,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
    polls,
    selectedPoll,
    isVoting,
    isCreating,
    feedbackMessage,
  ];
}

class PollsErrorState extends PollsState {
  final String message;

  const PollsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
