import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/enums/notification_type.dart';
import 'package:football_reservation/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:football_reservation/features/notifications/data/models/notification_model.dart';
import 'package:football_reservation/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:football_reservation/features/notifications/domain/entities/notification_entity.dart';
import 'package:football_reservation/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:football_reservation/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:football_reservation/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:football_reservation/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:football_reservation/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:football_reservation/features/notifications/presentation/bloc/notifications_state.dart';

void main() {
  group('Notifications Domain & Data Model Tests', () {
    final testDate = DateTime(2026, 11, 9, 12, 0);

    test('NotificationEntity equality and copyWith', () {
      final notif1 = NotificationEntity(
        id: 'n1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.waitingListPromoted,
        targetId: 'm1',
        isRead: false,
        createdAt: testDate,
      );

      final notif2 = NotificationEntity(
        id: 'n1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.waitingListPromoted,
        targetId: 'm1',
        isRead: false,
        createdAt: testDate,
      );

      expect(notif1, equals(notif2));

      final updated = notif1.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, 'n1');
      expect(notif1.isRead, isFalse);
    });

    test('NotificationModel serializes to JSON and from JSON accurately', () {
      final model = NotificationModel(
        id: 'n10',
        title: 'Match Alert',
        body: 'Your match starts in 1 hour',
        type: NotificationType.lineupPublished,
        targetId: 'match_99',
        isRead: false,
        createdAt: testDate,
      );

      final json = model.toJson();
      expect(json['id'], 'n10');
      expect(json['title'], 'Match Alert');
      expect(json['type'], 'lineupPublished');
      expect(json['targetId'], 'match_99');
      expect(json['isRead'], false);

      final parsed = NotificationModel.fromJson({
        'id': 'n10',
        'title': 'Match Alert',
        'body': 'Your match starts in 1 hour',
        'type': 'lineupPublished',
        'targetId': 'match_99',
        'isRead': false,
        'createdAt': testDate.toIso8601String(),
      });

      expect(parsed.id, model.id);
      expect(parsed.type, NotificationType.lineupPublished);
      expect(parsed.targetId, 'match_99');
    });

    test('NotificationModel copyWith returns NotificationModel', () {
      final model = NotificationModel(
        id: 'n1',
        title: 'Test',
        body: 'Body',
        type: NotificationType.motmPollStarted,
        isRead: false,
        createdAt: testDate,
      );

      final copied = model.copyWith(isRead: true);
      expect(copied, isA<NotificationModel>());
      expect(copied.isRead, isTrue);
      expect(copied.type, NotificationType.motmPollStarted);
    });
  });

  group('MockNotificationRemoteDataSource & Repository Tests', () {
    late MockNotificationRemoteDataSource dataSource;
    late NotificationRepositoryImpl repository;

    setUp(() {
      dataSource = MockNotificationRemoteDataSource();
      repository = NotificationRepositoryImpl(dataSource);
    });

    test(
      'getNotifications returns pre-seeded items sorted by date descending',
      () async {
        final result = await repository.getNotifications();
        expect(result.isSuccess, isTrue);

        final notifications = result.dataOrNull!;
        expect(notifications.length, greaterThanOrEqualTo(4));

        // Verify descending sort
        for (int i = 0; i < notifications.length - 1; i++) {
          expect(
            notifications[i].createdAt.isAfter(
                  notifications[i + 1].createdAt,
                ) ||
                notifications[i].createdAt.isAtSameMomentAs(
                  notifications[i + 1].createdAt,
                ),
            isTrue,
          );
        }
      },
    );

    test(
      'markAsRead updates notification state and decreases unread count',
      () async {
        final initialRes = await repository.getNotifications();
        final initialList = initialRes.dataOrNull!;
        final unreadItem = initialList.firstWhere((n) => !n.isRead);

        final markResult = await repository.markAsRead(unreadItem.id);
        expect(markResult.isSuccess, isTrue);

        final updatedRes = await repository.getNotifications();
        final updatedList = updatedRes.dataOrNull!;
        final updatedItem = updatedList.firstWhere(
          (n) => n.id == unreadItem.id,
        );
        expect(updatedItem.isRead, isTrue);
      },
    );

    test('markAllAsRead marks every notification as read', () async {
      final markAllResult = await repository.markAllAsRead();
      expect(markAllResult.isSuccess, isTrue);

      final notifications = (await repository.getNotifications()).dataOrNull!;
      for (final n in notifications) {
        expect(n.isRead, isTrue);
      }
    });
  });

  group('NotificationsBloc Tests', () {
    late MockNotificationRemoteDataSource dataSource;
    late NotificationRepositoryImpl repository;
    late GetNotificationsUseCase getNotificationsUseCase;
    late MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
    late MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
    late NotificationsBloc bloc;

    setUp(() {
      dataSource = MockNotificationRemoteDataSource();
      repository = NotificationRepositoryImpl(dataSource);
      getNotificationsUseCase = GetNotificationsUseCase(repository);
      markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(repository);
      markAllNotificationsAsReadUseCase = MarkAllNotificationsAsReadUseCase(
        repository,
      );

      bloc = NotificationsBloc(
        getNotificationsUseCase: getNotificationsUseCase,
        markNotificationAsReadUseCase: markNotificationAsReadUseCase,
        markAllNotificationsAsReadUseCase: markAllNotificationsAsReadUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is NotificationsInitial', () {
      expect(bloc.state, isA<NotificationsInitial>());
    });

    test(
      'LoadNotificationsRequested emits NotificationsLoading then NotificationsLoaded',
      () async {
        final expectedStates = [
          isA<NotificationsLoading>(),
          isA<NotificationsLoaded>()
              .having((s) => s.notifications.isNotEmpty, 'has items', isTrue)
              .having((s) => s.unreadCount, 'unreadCount', greaterThan(0)),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadNotificationsRequested());
      },
    );

    test(
      'MarkNotificationAsReadRequested updates read status in state',
      () async {
        bloc.add(const LoadNotificationsRequested());
        await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

        final loadedState = bloc.state as NotificationsLoaded;
        final initialUnread = loadedState.unreadCount;
        final target = loadedState.notifications.firstWhere((n) => !n.isRead);

        bloc.add(MarkNotificationAsReadRequested(target.id));

        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<NotificationsLoaded>()
                .having(
                  (s) => s.notifications
                      .firstWhere((n) => n.id == target.id)
                      .isRead,
                  'target isRead',
                  isTrue,
                )
                .having((s) => s.unreadCount, 'unreadCount', initialUnread - 1),
          ),
        );
      },
    );

    test('MarkAllNotificationsAsReadRequested sets unreadCount to 0', () async {
      bloc.add(const LoadNotificationsRequested());
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      bloc.add(const MarkAllNotificationsAsReadRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<NotificationsLoaded>()
              .having((s) => s.unreadCount, 'unreadCount', 0)
              .having(
                (s) => s.notifications.every((n) => n.isRead),
                'all read',
                isTrue,
              ),
        ),
      );
    });
  });
}
