import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/match_status.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/player_withdrawal_entity.dart';
import 'match_registration_model.dart';
import 'match_result_model.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.title,
    required super.pitchName,
    required super.location,
    required super.matchDateTime,
    required super.maxPlayers,
    required super.feePerPlayer,
    required super.status,
    super.courtType,
    super.pitchDimensions,
    super.confirmedPlayers,
    super.waitingList,
    super.withdrawals,
    super.result,
    super.isRecurringWeekly,
    super.isAutoLineupEnabled,
    super.registrationOpensAt,
    required super.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final confirmedList = (json['confirmedPlayers'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              MatchRegistrationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final waitList = (json['waitingList'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              MatchRegistrationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final withdrawalsList = (json['withdrawals'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              PlayerWithdrawalEntity.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final resultJson = json['result'] as Map<String, dynamic>?;
    final matchResult = resultJson != null
        ? MatchResultModel.fromJson(resultJson)
        : null;

    final regOpensAtRaw = json['registrationOpensAt'];
    final DateTime? registrationOpensAt = regOpensAtRaw != null
        ? (regOpensAtRaw is Timestamp
              ? regOpensAtRaw.toDate()
              : DateTime.tryParse(regOpensAtRaw.toString()))
        : null;

    return MatchModel(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      pitchName: json['pitchName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      matchDateTime: json['matchDateTime'] != null
          ? (json['matchDateTime'] is Timestamp
                ? (json['matchDateTime'] as Timestamp).toDate()
                : DateTime.tryParse(json['matchDateTime'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 14,
      feePerPlayer: (json['feePerPlayer'] as num?)?.toDouble() ?? 35.0,
      status: MatchStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MatchStatus.upcoming,
      ),
      courtType: json['courtType'] as String? ?? 'صالة مغطاة (عشب صناعي)',
      pitchDimensions: json['pitchDimensions'] as String? ?? '25 × 40 m',
      confirmedPlayers: confirmedList,
      waitingList: waitList,
      withdrawals: withdrawalsList,
      result: matchResult,
      isRecurringWeekly: json['isRecurringWeekly'] as bool? ?? false,
      isAutoLineupEnabled: json['isAutoLineupEnabled'] as bool? ?? true,
      registrationOpensAt: registrationOpensAt,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
                ? (json['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
    );
  }

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MatchModel.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pitchName': pitchName,
      'location': location,
      'matchDateTime': Timestamp.fromDate(matchDateTime),
      'maxPlayers': maxPlayers,
      'feePerPlayer': feePerPlayer,
      'status': status.name,
      'courtType': courtType,
      'pitchDimensions': pitchDimensions,
      'confirmedPlayers': confirmedPlayers
          .map((p) => MatchRegistrationModel.fromEntity(p).toJson())
          .toList(),
      'waitingList': waitingList
          .map((p) => MatchRegistrationModel.fromEntity(p).toJson())
          .toList(),
      'withdrawals': withdrawals.map((w) => w.toJson()).toList(),
      if (result != null)
        'result': MatchResultModel.fromEntity(result!).toJson(),
      'isRecurringWeekly': isRecurringWeekly,
      'isAutoLineupEnabled': isAutoLineupEnabled,
      if (registrationOpensAt != null)
        'registrationOpensAt': Timestamp.fromDate(registrationOpensAt!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MatchModel.fromEntity(MatchEntity entity) {
    return MatchModel(
      id: entity.id,
      title: entity.title,
      pitchName: entity.pitchName,
      location: entity.location,
      matchDateTime: entity.matchDateTime,
      maxPlayers: entity.maxPlayers,
      feePerPlayer: entity.feePerPlayer,
      status: entity.status,
      courtType: entity.courtType,
      pitchDimensions: entity.pitchDimensions,
      confirmedPlayers: entity.confirmedPlayers,
      waitingList: entity.waitingList,
      withdrawals: entity.withdrawals,
      result: entity.result != null
          ? MatchResultModel.fromEntity(entity.result!)
          : null,
      isRecurringWeekly: entity.isRecurringWeekly,
      isAutoLineupEnabled: entity.isAutoLineupEnabled,
      registrationOpensAt: entity.registrationOpensAt,
      createdAt: entity.createdAt,
    );
  }
}
