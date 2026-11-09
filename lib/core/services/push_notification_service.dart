import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler required by Firebase Cloud Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase already initialized
  }
  debugPrint(
    'FCM Background message: [${message.messageId}] ${message.notification?.title} - ${message.notification?.body}',
  );
}

/// Enterprise push notification service managing FCM permissions, device tokens,
/// background & foreground push handlers, local heads-up banners, and topic subscriptions.
class PushNotificationService {
  final FirebaseMessaging? _customMessaging;
  final FirebaseFirestore? _customFirestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
        'kickoff_high_importance_channel',
        'إشعارات المباريات والحجوزات العاجلة',
        description:
            'تنبيهات فورية عند فتح حجز المباريات وتصعيد قوائم الانتظار',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  PushNotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _customMessaging = messaging,
       _customFirestore = firestore,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  FirebaseMessaging get _messaging =>
      _customMessaging ?? FirebaseMessaging.instance;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  final _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  final _notificationOpenedController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onNotificationOpened =>
      _notificationOpenedController.stream;

  String? _cachedToken;
  String? get fcmToken => _cachedToken;
  bool _isInitialized = false;

  bool get isSupportedPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Initialize Firebase Messaging, local heads-up notifications, and event listeners.
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!isSupportedPlatform) {
      debugPrint(
        'PushNotificationService: FCM push notifications are not supported on this platform (${defaultTargetPlatform.name}).',
      );
      _isInitialized = true;
      return;
    }

    try {
      // 1. Initialize local notification plugin for in-app heads-up banner
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Local notification clicked: ${response.payload}');
        },
      );

      // Create Android Notification Channel for heads-up alerts
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_highImportanceChannel);

      // 2. Request user permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        'FCM Notification permission status: ${settings.authorizationStatus}',
      );

      // 3. Set iOS foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 5. Listen to FCM registration token events (Firebase Messaging modern API)
      _messaging.onRegistered.listen((token) {
        _cachedToken = token;
        debugPrint('FCM Device Token registered: $token');
      });

      // 6. Register current app instance with FCM
      try {
        await _messaging.register();
      } catch (regError) {
        debugPrint('FCM registration call note: $regError');
      }

      // 7. Foreground message listener -> Display Heads-up banner
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'FCM Foreground Message: ${message.notification?.title} - ${message.notification?.body}',
        );
        _foregroundMessageController.add(message);

        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _highImportanceChannel.id,
                _highImportanceChannel.name,
                channelDescription: _highImportanceChannel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data['targetId'] ?? message.data['route'] ?? '',
          );
        }
      });

      // 8. Notification tapped while app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Message opened from background: ${message.messageId}');
        _notificationOpenedController.add(message);
      });

      // 9. Check if app was opened from terminated state by a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          'FCM App launched from terminated notification: ${initialMessage.messageId}',
        );
        _notificationOpenedController.add(initialMessage);
      }

      // 10. Automatically subscribe all devices to the group topics
      await subscribeToTopic('kickoff_all');
      await subscribeToTopic('match_alerts');
      await subscribeToTopic('team_alerts');
      await subscribeToTopic('poll_alerts');

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  /// Save or update the user's FCM device token in Cloud Firestore.
  Future<void> saveTokenToUser(String userId) async {
    if (_cachedToken == null || userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([_cachedToken]),
        'lastFcmUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('FCM token successfully registered for user: $userId');
    } catch (e) {
      debugPrint('Failed to save FCM token to Firestore: $e');
    }
  }

  /// Remove token when user signs out.
  Future<void> removeTokenFromUser(String userId) async {
    if (_cachedToken == null || userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([_cachedToken]),
      });
      debugPrint('FCM token removed for user: $userId');
    } catch (e) {
      debugPrint('Failed to remove FCM token from Firestore: $e');
    }
  }

  /// Subscribe to global broadcast topics (e.g. 'all_matches', 'all_polls').
  Future<void> subscribeToTopic(String topic) async {
    if (!isSupportedPlatform) return;
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('FCM subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FCM subscribe to topic error ($topic): $e');
    }
  }

  /// Unsubscribe from broadcast topics.
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!isSupportedPlatform) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('FCM unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('FCM unsubscribe from topic error ($topic): $e');
    }
  }

  void dispose() {
    _foregroundMessageController.close();
    _notificationOpenedController.close();
  }
}
