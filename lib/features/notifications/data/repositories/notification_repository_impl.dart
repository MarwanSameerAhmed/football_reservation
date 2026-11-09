import '../../../../core/errors/failures.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  const NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications({
    String? userId,
  }) async {
    try {
      final list = await _remoteDataSource.getNotifications(userId: userId);
      return Success(list);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
      return const Success(null);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllAsRead({String? userId}) async {
    try {
      await _remoteDataSource.markAllAsRead(userId: userId);
      return const Success(null);
    } on AppException catch (e) {
      return FailureResult(ServerFailure(e.message, e.code));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<int> watchUnreadCount({String? userId}) =>
      _remoteDataSource.watchUnreadCount(userId: userId);
}
