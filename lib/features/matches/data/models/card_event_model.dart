import '../../domain/entities/card_event_entity.dart';

class CardEventModel extends CardEventEntity {
  const CardEventModel({
    required super.id,
    required super.playerId,
    required super.playerName,
    super.isRedCard = false,
    super.minute,
    super.reason,
  });

  factory CardEventModel.fromEntity(CardEventEntity entity) {
    return CardEventModel(
      id: entity.id,
      playerId: entity.playerId,
      playerName: entity.playerName,
      isRedCard: entity.isRedCard,
      minute: entity.minute,
      reason: entity.reason,
    );
  }

  factory CardEventModel.fromJson(Map<String, dynamic> json) {
    return CardEventModel(
      id: json['id'] as String? ?? '',
      playerId: json['playerId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? '',
      isRedCard: json['isRedCard'] as bool? ?? false,
      minute: json['minute'] as int?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'playerName': playerName,
      'isRedCard': isRedCard,
      if (minute != null) 'minute': minute,
      if (reason != null) 'reason': reason,
    };
  }
}
