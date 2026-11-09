import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/services/firebase_notification_sender_service.dart';
import '../../domain/usecases/cancel_match_registration_usecase.dart';
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
  final FirebaseNotificationSenderService? _notificationSenderService;

  MatchesBloc({
    required GetMatchesUseCase getMatchesUseCase,
    required GetMatchByIdUseCase getMatchByIdUseCase,
    required RegisterPlayerToMatchUseCase registerPlayerToMatchUseCase,
    required CancelMatchRegistrationUseCase cancelMatchRegistrationUseCase,
    RecordMatchResultUseCase? recordMatchResultUseCase,
    FirebaseNotificationSenderService? notificationSenderService,
  }) : _getMatchesUseCase = getMatchesUseCase,
       _getMatchByIdUseCase = getMatchByIdUseCase,
       _registerPlayerToMatchUseCase = registerPlayerToMatchUseCase,
       _cancelMatchRegistrationUseCase = cancelMatchRegistrationUseCase,
       _recordMatchResultUseCase = recordMatchResultUseCase,
       _notificationSenderService = notificationSenderService,
       super(const MatchesInitial()) {
    on<LoadMatchesRequested>(_onLoadMatchesRequested);
    on<SelectMatchRequested>(_onSelectMatchRequested);
    on<RegisterPlayerRequested>(_onRegisterPlayerRequested);
    on<CancelRegistrationRequested>(_onCancelRegistrationRequested);
    on<RecordMatchResultRequested>(_onRecordMatchResultRequested);
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
    );

    result.fold(
      onSuccess: (updatedMatch) {
        const msg = 'تم إلغاء تسجيل حضورك في المباراة وتحديث القائمة.';

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
}
