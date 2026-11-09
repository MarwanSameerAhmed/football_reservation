import 'package:equatable/equatable.dart';
import '../../../../core/enums/match_status.dart';
import 'match_registration_entity.dart';
import 'match_result_entity.dart';

class MatchEntity extends Equatable {
  final String id;
  final String title;
  final String pitchName;
  final String location;
  final DateTime matchDateTime;
  final int maxPlayers;
  final double feePerPlayer;
  final MatchStatus status;
  final String courtType; // e.g. 'صالة مغطاة / عشب صناعي' or 'ملعب خارجي'
  final String pitchDimensions; // e.g. '25 × 40 m'
  final List<MatchRegistrationEntity> confirmedPlayers;
  final List<MatchRegistrationEntity> waitingList;
  final MatchResultEntity? result;
  final DateTime createdAt;

  const MatchEntity({
    required this.id,
    required this.title,
    required this.pitchName,
    required this.location,
    required this.matchDateTime,
    required this.maxPlayers,
    required this.feePerPlayer,
    required this.status,
    this.courtType = 'صالة مغطاة (عشب صناعي)',
    this.pitchDimensions = '25 × 40 m',
    this.confirmedPlayers = const [],
    this.waitingList = const [],
    this.result,
    required this.createdAt,
  });

  bool get isSquadFull => confirmedPlayers.length >= maxPlayers;

  int get availableSpots =>
      (maxPlayers - confirmedPlayers.length).clamp(0, maxPlayers);

  bool isPlayerRegistered(String playerId) {
    return confirmedPlayers.any((r) => r.playerId == playerId) ||
        waitingList.any((r) => r.playerId == playerId);
  }

  MatchRegistrationEntity? getPlayerRegistration(String playerId) {
    for (final r in confirmedPlayers) {
      if (r.playerId == playerId) return r;
    }
    for (final r in waitingList) {
      if (r.playerId == playerId) return r;
    }
    return null;
  }

  MatchEntity copyWith({
    String? id,
    String? title,
    String? pitchName,
    String? location,
    DateTime? matchDateTime,
    int? maxPlayers,
    double? feePerPlayer,
    MatchStatus? status,
    String? courtType,
    String? pitchDimensions,
    List<MatchRegistrationEntity>? confirmedPlayers,
    List<MatchRegistrationEntity>? waitingList,
    MatchResultEntity? result,
    DateTime? createdAt,
  }) {
    return MatchEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      pitchName: pitchName ?? this.pitchName,
      location: location ?? this.location,
      matchDateTime: matchDateTime ?? this.matchDateTime,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      feePerPlayer: feePerPlayer ?? this.feePerPlayer,
      status: status ?? this.status,
      courtType: courtType ?? this.courtType,
      pitchDimensions: pitchDimensions ?? this.pitchDimensions,
      confirmedPlayers: confirmedPlayers ?? this.confirmedPlayers,
      waitingList: waitingList ?? this.waitingList,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    pitchName,
    location,
    matchDateTime,
    maxPlayers,
    feePerPlayer,
    status,
    courtType,
    pitchDimensions,
    confirmedPlayers,
    waitingList,
    result,
    createdAt,
  ];
}
