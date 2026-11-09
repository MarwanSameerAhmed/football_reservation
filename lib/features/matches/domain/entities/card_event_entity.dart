import 'package:equatable/equatable.dart';

/// Pure domain entity representing a booking (Yellow or Red card) in a match.
class CardEventEntity extends Equatable {
  final String id;
  final String playerId;
  final String playerName;
  final bool isRedCard;
  final int? minute;
  final String? reason;

  const CardEventEntity({
    required this.id,
    required this.playerId,
    required this.playerName,
    this.isRedCard = false,
    this.minute,
    this.reason,
  });

  CardEventEntity copyWith({
    String? id,
    String? playerId,
    String? playerName,
    bool? isRedCard,
    int? minute,
    String? reason,
  }) {
    return CardEventEntity(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isRedCard: isRedCard ?? this.isRedCard,
      minute: minute ?? this.minute,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    playerId,
    playerName,
    isRedCard,
    minute,
    reason,
  ];
}
