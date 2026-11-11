import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/services/firebase_notification_sender_service.dart';
import '../../domain/usecases/cancel_match_registration_usecase.dart';
import '../../domain/usecases/create_match_usecase.dart';
import '../../domain/usecases/get_match_by_id_usecase.dart';
import '../../domain/usecases/get_matches_usecase.dart';
import '../../domain/usecases/record_match_result_usecase.dart';
import '../../domain/usecases/register_player_to_match_usecase.dart';
import 'matches_event.dart';
import 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final GetMatchesUseCase _getMatchesUseCase;
  final GetMatchByIdUseCase _getMatchByIdUseCase;
  final RegisterPlayerToMatchUseCase _registerPlayerToMatchUseCase;
  final CancelMatchRegistrationUseCase _cancelMatchRegistrationUseCase;
  final RecordMatchResultUseCase? _recordMatchResultUseCase;
  final CreateMatchUseCase? _createMatchUseCase;
  final FirebaseNotificationSenderService? _notificationSenderService;

  MatchesBloc({
    required GetMatchesUseCase getMatchesUseCase,
    required GetMatchByIdUseCase getMatchByIdUseCase,
    required RegisterPlayerToMatchUseCase registerPlayerToMatchUseCase,
    required CancelMatchRegistrationUseCase cancelMatchRegistrationUseCase,
    RecordMatchResultUseCase? recordMatchResultUseCase,
    CreateMatchUseCase? createMatchUseCase,
    FirebaseNotificationSenderService? notificationSenderService,
  }) : _getMatchesUseCase = getMatchesUseCase,
       _getMatchByIdUseCase = getMatchByIdUseCase,
       _registerPlayerToMatchUseCase = registerPlayerToMatchUseCase,
       _cancelMatchRegistrationUseCase = cancelMatchRegistrationUseCase,
       _recordMatchResultUseCase = recordMatchResultUseCase,
       _createMatchUseCase = createMatchUseCase,
       _notificationSenderService = notificationSenderService,
       super(const MatchesInitial()) {
    on<LoadMatchesRequested>(_onLoadMatchesRequested);
    on<SelectMatchRequested>(_onSelectMatchRequested);
    on<RegisterPlayerRequested>(_onRegisterPlayerRequested);
    on<CancelRegistrationRequested>(_onCancelRegistrationRequested);
    on<RecordMatchResultRequested>(_onRecordMatchResultRequested);
    on<CreateMatchRequested>(_onCreateMatchRequested);
    on<PromotePlayerToConfirmedRequested>(_onPromotePlayerToConfirmedRequested);
    on<DemotePlayerToWaitlistRequested>(_onDemotePlayerToWaitlistRequested);
  }

  Future<void> _onLoadMatchesRequested(
    LoadMatchesRequested event,
    Emitter<MatchesState> emit,
  ) async {
    emit(const MatchesLoading());
    final result = await _getMatchesUseCase(status: event.statusFilter);
    result.fold(
      onSuccess: (matches) {
        if (matches.isEmpty) {
          emit(const MatchesEmptyState());
        } else {
          emit(MatchesLoaded(matches: matches, selectedMatch: matches.first));
        }
      },
      onFailure: (failure) => emit(MatchesErrorState(failure.message)),
    );
  }

  Future<void> _onSelectMatchRequested(
    SelectMatchRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    if (currentState is MatchesLoaded) {
      final match = currentState.matches.firstWhere(
        (m) => m.id == event.matchId,
        orElse: () => currentState.selectedMatch!,
      );
      emit(currentState.copyWith(selectedMatch: match));
    } else {
      final result = await _getMatchByIdUseCase(event.matchId);
      result.fold(
        onSuccess: (match) =>
            emit(MatchesLoaded(matches: [match], selectedMatch: match)),
        onFailure: (failure) => emit(MatchesErrorState(failure.message)),
      );
    }
  }

  Future<void> _onRegisterPlayerRequested(
    RegisterPlayerRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    final result = await _registerPlayerToMatchUseCase(
      matchId: event.matchId,
      playerId: event.playerId,
      playerName: event.playerName,
      position: event.position,
    );

    result.fold(
      onSuccess: (updatedMatch) {
        final isConfirmed = updatedMatch.confirmedPlayers.any(
          (p) => p.playerId == event.playerId,
        );
        final msg = isConfirmed
            ? 'تم تأكيد تسجيل حضورك بنجاح في التشكيلة الأساسية! ⚽'
            : 'تمت إضافتك إلى قائمة الانتظار للمباراة بنجاح! ⏳';

        if (currentState is MatchesLoaded) {
          final updatedMatches = currentState.matches.map((m) {
            return m.id == updatedMatch.id ? updatedMatch : m;
          }).toList();

          emit(
            currentState.copyWith(
              matches: updatedMatches,
              selectedMatch: updatedMatch,
              successMessage: msg,
            ),
          );
        } else {
          emit(
            MatchesLoaded(
              matches: [updatedMatch],
              selectedMatch: updatedMatch,
              successMessage: msg,
            ),
          );
        }
      },
      onFailure: (failure) => emit(MatchesErrorState(failure.message)),
    );
  }

  Future<void> _onCancelRegistrationRequested(
    CancelRegistrationRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    final result = await _cancelMatchRegistrationUseCase(
      matchId: event.matchId,
      playerId: event.playerId,
      playerName: event.playerName,
      reason: event.reason,
      customNote: event.customNote,
    );

    result.fold(
      onSuccess: (updatedMatch) {
        final msg = event.reason != null && event.reason!.isNotEmpty
            ? 'تم تسجيل اعتذارك وإبلاغ الكابتن بنجاح ⚠️'
            : 'تم إلغاء تسجيل حضورك في المباراة وتحديث القائمة.';

        // If withdrawal reason is provided, notify the Admin/Captain
        if (event.reason != null && event.reason!.isNotEmpty) {
          _notificationSenderService?.sendPlayerWithdrawalNotification(
            playerName: event.playerName ?? 'أحد اللاعبين',
            matchTitle: updatedMatch.title,
            reason: event.reason!,
            customNote: event.customNote,
          );
        }

        // Check if a player from waitlist was promoted to confirmed squad
        final previousConfirmedIds = currentState is MatchesLoaded
            ? currentState.selectedMatch?.confirmedPlayers
                      .map((p) => p.playerId)
                      .toSet() ??
                  {}
            : <String>{};
        final newlyConfirmed = updatedMatch.confirmedPlayers
            .where(
              (p) =>
                  !previousConfirmedIds.contains(p.playerId) &&
                  p.playerId != event.playerId,
            )
            .toList();

        if (newlyConfirmed.isNotEmpty) {
          final promoted = newlyConfirmed.first;
          _notificationSenderService?.sendWaitlistPromotedNotification(
            playerName: promoted.playerName,
            matchTitle: updatedMatch.title,
            matchId: updatedMatch.id,
          );
        }

        if (currentState is MatchesLoaded) {
          final updatedMatches = currentState.matches.map((m) {
            return m.id == updatedMatch.id ? updatedMatch : m;
          }).toList();

          emit(
            currentState.copyWith(
              matches: updatedMatches,
              selectedMatch: updatedMatch,
              successMessage: msg,
            ),
          );
        } else {
          emit(
            MatchesLoaded(
              matches: [updatedMatch],
              selectedMatch: updatedMatch,
              successMessage: msg,
            ),
          );
        }
      },
      onFailure: (failure) => emit(MatchesErrorState(failure.message)),
    );
  }

  Future<void> _onRecordMatchResultRequested(
    RecordMatchResultRequested event,
    Emitter<MatchesState> emit,
  ) async {
    if (_recordMatchResultUseCase == null) return;

    final result = await _recordMatchResultUseCase(event.result);
    result.fold(
      onSuccess: (savedResult) {
        final currentState = state;
        if (currentState is MatchesLoaded) {
          final updatedMatches = currentState.matches.map((m) {
            if (m.id == savedResult.matchId) {
              return m.copyWith(
                status: MatchStatus.completed,
                result: savedResult,
              );
            }
            return m;
          }).toList();

          final updatedSelected =
              currentState.selectedMatch?.id == savedResult.matchId
              ? currentState.selectedMatch!.copyWith(
                  status: MatchStatus.completed,
                  result: savedResult,
                )
              : currentState.selectedMatch;

          _notificationSenderService?.sendMatchResultsPublishedNotification(
            matchTitle: updatedSelected?.title ?? 'المباراة',
            winningTeam: savedResult.winnerTeamName,
            motmName: savedResult.manOfTheMatchName,
          );

          emit(
            currentState.copyWith(
              matches: updatedMatches,
              selectedMatch: updatedSelected,
              successMessage: 'تم تثبيت نتيجة المباراة واعتمادها رسمياً ⚽🏆',
            ),
          );
        }
      },
      onFailure: (failure) => emit(MatchesErrorState(failure.message)),
    );
  }

  Future<void> _onCreateMatchRequested(
    CreateMatchRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final createUseCase = _createMatchUseCase;
    if (createUseCase == null) return;
    emit(const MatchesLoading());
    final result = await createUseCase(event.match);
    result.fold(
      onSuccess: (newMatch) {
        if (newMatch.registrationOpensAt != null &&
            DateTime.now().isBefore(newMatch.registrationOpensAt!)) {
          final openTimeStr =
              '${newMatch.registrationOpensAt!.hour}:${newMatch.registrationOpensAt!.minute.toString().padLeft(2, '0')}';
          _notificationSenderService?.sendAdminBroadcast(
            title: '📢 تم جدولة مباراة جديدة: ${newMatch.title}',
            message:
                'تم الإعلان عن تفاصيل المباراة! يفتح باب التسجيل وحجز المقاعد في تمام الساعة $openTimeStr ⏰',
          );
        } else {
          _notificationSenderService?.sendMatchCreatedNotification(
            matchId: newMatch.id,
            matchTitle: newMatch.title,
            matchDate:
                '${newMatch.matchDateTime.year}-${newMatch.matchDateTime.month}-${newMatch.matchDateTime.day}',
            matchTime:
                '${newMatch.matchDateTime.hour}:${newMatch.matchDateTime.minute.toString().padLeft(2, '0')}',
            stadium: newMatch.pitchName,
          );
        }
        add(const LoadMatchesRequested());
      },
      onFailure: (failure) => emit(MatchesErrorState(failure.message)),
    );
  }

  Future<void> _onPromotePlayerToConfirmedRequested(
    PromotePlayerToConfirmedRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    final matchIndex =
        currentState.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = currentState.matches[matchIndex];
    final waitPlayerIndex =
        match.waitingList.indexWhere((p) => p.playerId == event.playerId);
    if (waitPlayerIndex == -1) return;

    final player = match.waitingList[waitPlayerIndex];
    final updatedWaiting = List.of(match.waitingList)..removeAt(waitPlayerIndex);
    final updatedConfirmed = List.of(match.confirmedPlayers)..add(player);

    final updatedMatch = match.copyWith(
      confirmedPlayers: updatedConfirmed,
      waitingList: updatedWaiting,
    );

    final updatedMatches = List.of(currentState.matches)..[matchIndex] = updatedMatch;
    emit(
      currentState.copyWith(
        matches: updatedMatches,
        selectedMatch: updatedMatch,
        successMessage:
            'تمت ترقية اللاعب ${player.playerName} إلى التشكيلة الأساسية ⬆️',
      ),
    );
  }

  Future<void> _onDemotePlayerToWaitlistRequested(
    DemotePlayerToWaitlistRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    final matchIndex =
        currentState.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = currentState.matches[matchIndex];
    final confPlayerIndex =
        match.confirmedPlayers.indexWhere((p) => p.playerId == event.playerId);
    if (confPlayerIndex == -1) return;

    final player = match.confirmedPlayers[confPlayerIndex];
    final updatedConfirmed = List.of(match.confirmedPlayers)
      ..removeAt(confPlayerIndex);
    final updatedWaiting = List.of(match.waitingList)..add(player);

    final updatedMatch = match.copyWith(
      confirmedPlayers: updatedConfirmed,
      waitingList: updatedWaiting,
    );

    final updatedMatches = List.of(currentState.matches)..[matchIndex] = updatedMatch;
    emit(
      currentState.copyWith(
        matches: updatedMatches,
        selectedMatch: updatedMatch,
        successMessage:
            'تم إنزال اللاعب ${player.playerName} إلى قائمة الانتظار ⬇️',
      ),
    );
  }
}
