import 'package:equatable/equatable.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/registration_status.dart';

class MatchRegistrationEntity extends Equatable {
  final String id;
  final String matchId;
  final String playerId;
  final String playerName;
  final PlayerPosition playerPosition;
  final DateTime registeredAt;
  final RegistrationStatus status;
  final int? queuePosition; // 1, 2, 3... for waiting list

  const MatchRegistrationEntity({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.playerPosition,
    required this.registeredAt,
    required this.status,
    this.queuePosition,
  });

  bool get isConfirmed => status == RegistrationStatus.confirmed;
  bool get isWaiting => status == RegistrationStatus.waiting;
  bool get isCancelled => status == RegistrationStatus.cancelled;

  MatchRegistrationEntity copyWith({
    String? id,
    String? matchId,
    String? playerId,
    String? playerName,
    PlayerPosition? playerPosition,
    DateTime? registeredAt,
    RegistrationStatus? status,
    int? queuePosition,
    bool clearQueuePosition = false,
  }) {
    return MatchRegistrationEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerPosition: playerPosition ?? this.playerPosition,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      queuePosition: clearQueuePosition
          ? null
          : (queuePosition ?? this.queuePosition),
    );
  }

  @override
  List<Object?> get props => [
    id,
    matchId,
    playerId,
    playerName,
    playerPosition,
    registeredAt,
    status,
    queuePosition,
  ];
}
