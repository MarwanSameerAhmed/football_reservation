import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  Future<Result<void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
