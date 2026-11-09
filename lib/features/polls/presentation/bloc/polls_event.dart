import 'package:equatable/equatable.dart';
import '../../domain/entities/poll_entity.dart';

abstract class PollsEvent extends Equatable {
  const PollsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPollsRequested extends PollsEvent {
  final String? matchId;
  final bool? activeOnly;

  const LoadPollsRequested({this.matchId, this.activeOnly});

  @override
  List<Object?> get props => [matchId, activeOnly];
}

class SelectPollRequested extends PollsEvent {
  final String pollId;

  const SelectPollRequested(this.pollId);

  @override
  List<Object?> get props => [pollId];
}

class CastVoteRequested extends PollsEvent {
  final String pollId;
  final String optionId;
  final String userId;

  const CastVoteRequested({
    required this.pollId,
    required this.optionId,
    required this.userId,
  });

  @override
  List<Object?> get props => [pollId, optionId, userId];
}

class CreatePollRequested extends PollsEvent {
  final PollEntity poll;

  const CreatePollRequested(this.poll);

  @override
  List<Object?> get props => [poll];
}

class ClosePollRequested extends PollsEvent {
  final String pollId;

  const ClosePollRequested(this.pollId);

  @override
  List<Object?> get props => [pollId];
}
