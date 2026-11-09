import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/registration_status.dart';
import '../../domain/entities/match_registration_entity.dart';

class MatchRegistrationModel extends MatchRegistrationEntity {
  const MatchRegistrationModel({
    required super.id,
    required super.matchId,
    required super.playerId,
    required super.playerName,
    required super.playerPosition,
    required super.registeredAt,
    required super.status,
    super.queuePosition,
  });

  factory MatchRegistrationModel.fromJson(Map<String, dynamic> json) {
    return MatchRegistrationModel(
      id: json['id'] as String? ?? '',
      matchId: json['matchId'] as String? ?? '',
      playerId: json['playerId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? '',
      playerPosition: PlayerPosition.values.firstWhere(
        (p) => p.name == json['playerPosition'],
        orElse: () => PlayerPosition.midfielder,
      ),
      registeredAt: json['registeredAt'] != null
          ? (json['registeredAt'] is Timestamp
                ? (json['registeredAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['registeredAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      status: RegistrationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => RegistrationStatus.confirmed,
      ),
      queuePosition: (json['queuePosition'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'playerId': playerId,
      'playerName': playerName,
      'playerPosition': playerPosition.name,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'status': status.name,
      'queuePosition': queuePosition,
    };
  }

  factory MatchRegistrationModel.fromEntity(MatchRegistrationEntity entity) {
    return MatchRegistrationModel(
      id: entity.id,
      matchId: entity.matchId,
      playerId: entity.playerId,
      playerName: entity.playerName,
      playerPosition: entity.playerPosition,
      registeredAt: entity.registeredAt,
      status: entity.status,
      queuePosition: entity.queuePosition,
    );
  }
}
