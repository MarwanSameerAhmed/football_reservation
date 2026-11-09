import '../../../../core/utils/result.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  Future<Result<List<NotificationEntity>>> call({String? userId}) {
    return _repository.getNotifications(userId: userId);
  }
}
