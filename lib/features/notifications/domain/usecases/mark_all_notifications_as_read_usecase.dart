import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _repository;

  const MarkAllNotificationsAsReadUseCase(this._repository);

  Future<Result<void>> call({String? userId}) {
    return _repository.markAllAsRead(userId: userId);
  }
}
