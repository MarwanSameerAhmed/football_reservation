import 'package:equatable/equatable.dart';
import '../../../../core/enums/match_status.dart';
import 'match_registration_entity.dart';
import 'match_result_entity.dart';
import 'player_withdrawal_entity.dart';

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
  final List<PlayerWithdrawalEntity> withdrawals;
  final MatchResultEntity? result;
  final bool isRecurringWeekly;
  final bool isAutoLineupEnabled;
  final DateTime? registrationOpensAt;
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
    this.withdrawals = const [],
    this.result,
    this.isRecurringWeekly = false,
    this.isAutoLineupEnabled = true,
    this.registrationOpensAt,
    required this.createdAt,
  });

  bool get isSquadFull => confirmedPlayers.length >= maxPlayers;

  int get availableSpots =>
      (maxPlayers - confirmedPlayers.length).clamp(0, maxPlayers);

  /// Human-readable Arabic date and time string (e.g. الجمعة 14/11 • 8:30 م).
  String get formattedDateTime {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final dayName = days[(matchDateTime.weekday - 1) % 7];
    final hour = matchDateTime.hour > 12
        ? matchDateTime.hour - 12
        : (matchDateTime.hour == 0 ? 12 : matchDateTime.hour);
    final minute = matchDateTime.minute.toString().padLeft(2, '0');
    final period = matchDateTime.hour >= 12 ? 'م' : 'ص';
    return '$dayName ${matchDateTime.day}/${matchDateTime.month} • $hour:$minute $period';
  }

  /// Whether booking/registration is currently open or scheduled for a later time.
  bool get isRegistrationOpen =>
      registrationOpensAt == null || DateTime.now().isAfter(registrationOpensAt!);

  /// Duration until registration opens, if scheduled in the future.
  Duration? get timeUntilRegistrationOpens =>
      registrationOpensAt != null && DateTime.now().isBefore(registrationOpensAt!)
          ? registrationOpensAt!.difference(DateTime.now())
          : null;

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
    List<PlayerWithdrawalEntity>? withdrawals,
    MatchResultEntity? result,
    bool? isRecurringWeekly,
    bool? isAutoLineupEnabled,
    DateTime? registrationOpensAt,
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
      withdrawals: withdrawals ?? this.withdrawals,
      result: result ?? this.result,
      isRecurringWeekly: isRecurringWeekly ?? this.isRecurringWeekly,
      isAutoLineupEnabled: isAutoLineupEnabled ?? this.isAutoLineupEnabled,
      registrationOpensAt: registrationOpensAt ?? this.registrationOpensAt,
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
    withdrawals,
    result,
    isRecurringWeekly,
    isAutoLineupEnabled,
    registrationOpensAt,
    createdAt,
  ];
}
