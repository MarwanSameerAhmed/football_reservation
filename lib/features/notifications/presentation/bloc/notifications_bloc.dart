import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsReadUseCase;

  NotificationsBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
    required MarkAllNotificationsAsReadUseCase
    markAllNotificationsAsReadUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
       _markAllNotificationsAsReadUseCase = markAllNotificationsAsReadUseCase,
       super(const NotificationsInitial()) {
    on<LoadNotificationsRequested>(_onLoadNotificationsRequested);
    on<MarkNotificationAsReadRequested>(_onMarkNotificationAsReadRequested);
    on<MarkAllNotificationsAsReadRequested>(
      _onMarkAllNotificationsAsReadRequested,
    );
  }

  Future<void> _onLoadNotificationsRequested(
    LoadNotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase(userId: event.userId);
    result.fold(
      onSuccess: (list) {
        if (list.isEmpty) {
          emit(const NotificationsEmptyState());
        } else {
          emit(NotificationsLoaded(notifications: list));
        }
      },
      onFailure: (failure) => emit(NotificationsErrorState(failure.message)),
    );
  }

  Future<void> _onMarkNotificationAsReadRequested(
    MarkNotificationAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedList = currentState.notifications.map((n) {
        return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
      }).toList();
      emit(currentState.copyWith(notifications: updatedList));
    }
    await _markNotificationAsReadUseCase(event.notificationId);
  }

  Future<void> _onMarkAllNotificationsAsReadRequested(
    MarkAllNotificationsAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedList = currentState.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();
      emit(currentState.copyWith(notifications: updatedList));
    }
    await _markAllNotificationsAsReadUseCase(userId: event.userId);
  }
}
