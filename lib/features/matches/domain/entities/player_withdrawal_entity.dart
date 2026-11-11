import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a player's official withdrawal/excuse from an upcoming match,
/// including the reason, custom notes, and timestamp for the Captain/Admin to review.
class PlayerWithdrawalEntity extends Equatable {
  final String playerId;
  final String playerName;
  final String reason;
  final String? customNote;
  final DateTime withdrawnAt;

  const PlayerWithdrawalEntity({
    required this.playerId,
    required this.playerName,
    required this.reason,
    this.customNote,
    required this.withdrawnAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'reason': reason,
      'customNote': customNote,
      'withdrawnAt': withdrawnAt.toIso8601String(),
    };
  }

  factory PlayerWithdrawalEntity.fromJson(Map<String, dynamic> json) {
    return PlayerWithdrawalEntity(
      playerId: json['playerId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? 'لاعب',
      reason: json['reason'] as String? ?? 'ظرف طارئ',
      customNote: json['customNote'] as String?,
      withdrawnAt: json['withdrawnAt'] != null
          ? (json['withdrawnAt'] is Timestamp
                ? (json['withdrawnAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['withdrawnAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    playerId,
    playerName,
    reason,
    customNote,
    withdrawnAt,
  ];
}

