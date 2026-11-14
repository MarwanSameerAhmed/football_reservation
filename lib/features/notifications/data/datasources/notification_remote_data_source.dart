import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/notification_type.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({String? userId});

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead({String? userId});

  Stream<int> watchUnreadCount({String? userId});
}

class FirebaseNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  @override
  Future<List<NotificationModel>> getNotifications({String? userId}) async {
    try {
      final snapshot = await _notificationsCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead({String? userId}) async {
    try {
      final snapshot = await _notificationsCollection
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<int> watchUnreadCount({String? userId}) {
    return _notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }
}

/// Pre-seeded in-memory mock data source for immediate offline operation and testing.
class MockNotificationRemoteDataSource implements NotificationRemoteDataSource {
  final Map<String, NotificationModel> _notifications = {};
  final _unreadCountController = StreamController<int>.broadcast();
  final Duration delay;

  MockNotificationRemoteDataSource({
    this.delay = Duration.zero,
    bool seedDefault = true,
  }) {
    if (seedDefault) {
      _seedDefaultNotifications();
    }
  }

  void clearAll() {
    _notifications.clear();
    _unreadCountController.add(0);
  }

  void _seedDefaultNotifications() {
    final now = DateTime.now();
    final items = [
      NotificationModel(
        id: 'notif_1',
        title: 'ترقية إلى التشكيلة الأساسية ⏳⚽',
        body:
            'مبروك! بعد اعتذار أحد اللاعبين، تم تصعيدك رسمياً من قائمة الانتظار للمشاركة في مباراة الجمعة.',
        type: NotificationType.waitingListPromoted,
        targetId: 'm1',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'اعتماد تشكيلة كلاسيكو الأسبوع 📋⚡',
        body:
            'قام المولد التكتيكي الذكي باعتماد تشكيلة الفريق الأخضر ضد الأبيض. تصفح موقعك في الملعب الآن.',
        type: NotificationType.lineupPublished,
        targetId: 'm1',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'بدء تصويت رجل المباراة (MOTM) ⭐',
        body:
            'تم فتح باب التصويت لاختيار أفضل لاعب في المباراة الأخيرة. شارك بصوتك الآن.',
        type: NotificationType.motmPollStarted,
        targetId: 'poll_motm_1',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'تثبيت النتيجة الرسمية للمباراة 🏆',
        body:
            'انتهى الكلاسيكو بفوز الفريق الأخضر بنتيجة 4 - 3. تم تسجيل الأهداف وصناع اللعب في لوحة الصدارة.',
        type: NotificationType.matchResultPublished,
        targetId: 'm1',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    for (final n in items) {
      _notifications[n.id] = n;
    }
    _emitCount();
  }

  void _emitCount() {
    final unread = _notifications.values.where((n) => !n.isRead).length;
    _unreadCountController.add(unread);
  }

  @override
  Future<List<NotificationModel>> getNotifications({String? userId}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final list = _notifications.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final item = _notifications[notificationId];
    if (item != null) {
      _notifications[notificationId] = item.copyWith(isRead: true);
      _emitCount();
    }
  }

  @override
  Future<void> markAllAsRead({String? userId}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    for (final id in _notifications.keys) {
      final item = _notifications[id]!;
      _notifications[id] = item.copyWith(isRead: true);
    }
    _emitCount();
  }

  @override
  Stream<int> watchUnreadCount({String? userId}) =>
      _unreadCountController.stream;
}
