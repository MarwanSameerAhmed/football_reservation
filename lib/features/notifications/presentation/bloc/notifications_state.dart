import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsEmptyState extends NotificationsState {
  const NotificationsEmptyState();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;

  const NotificationsLoaded({required this.notifications});

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsLoaded copyWith({List<NotificationEntity>? notifications}) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [notifications];
}

class NotificationsErrorState extends NotificationsState {
  final String message;

  const NotificationsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
