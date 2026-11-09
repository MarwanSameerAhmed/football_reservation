import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsRequested extends NotificationsEvent {
  final String? userId;

  const LoadNotificationsRequested({this.userId});

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsReadRequested extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsReadRequested extends NotificationsEvent {
  final String? userId;

  const MarkAllNotificationsAsReadRequested({this.userId});

  @override
  List<Object?> get props => [userId];
}
