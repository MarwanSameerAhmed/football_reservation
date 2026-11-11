import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../config/firebase_admin_credentials.dart';

/// Enterprise Push Notification Sender Service powered by Firebase Cloud Messaging
/// HTTP v1 API and Google OAuth 2.0 Service Account credentials.
class FirebaseNotificationSenderService {
  final Map<String, dynamic> _credentialsMap;
  final http.Client? _customHttpClient;

  AuthClient? _authenticatedClient;
  DateTime? _tokenExpiry;

  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  static const String _fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/${FirebaseAdminCredentials.projectId}/messages:send';

  FirebaseNotificationSenderService({
    Map<String, dynamic>? credentialsMap,
    http.Client? httpClient,
  }) : _credentialsMap =
           credentialsMap ?? FirebaseAdminCredentials.serviceAccountMap,
       _customHttpClient = httpClient;

  /// Obtain or retrieve a cached OAuth 2.0 authenticated client.
  Future<http.Client> _getClient() async {
    if (_customHttpClient != null) return _customHttpClient;

    final now = DateTime.now();
    if (_authenticatedClient != null &&
        _tokenExpiry != null &&
        _tokenExpiry!.isAfter(now.add(const Duration(minutes: 5)))) {
      return _authenticatedClient!;
    }

    final accountCredentials = ServiceAccountCredentials.fromJson(
      _credentialsMap,
    );
    _authenticatedClient = await clientViaServiceAccount(
      accountCredentials,
      _scopes,
    );
    _tokenExpiry = _authenticatedClient?.credentials.accessToken.expiry;
    return _authenticatedClient!;
  }

  /// Sends a push notification message via FCM HTTP v1 API.
  /// Target can be a topic (e.g. 'kickoff_all') or a direct FCM registration token.
  Future<bool> sendNotification({
    String? topic,
    String? targetToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    assert(
      (topic != null && topic.isNotEmpty) ||
          (targetToken != null && targetToken.isNotEmpty),
      'Must specify either a topic or targetToken',
    );

    try {
      final client = await _getClient();

      final Map<String, dynamic> messagePayload = {
        'notification': {'title': title, 'body': body},
        'android': {
          'priority': 'HIGH',
          'notification': {
            'channel_id': 'kickoff_high_importance_channel',
            'sound': 'default',
            'default_sound': true,
            'default_vibrate_timings': true,
          },
        },
        'apns': {
          'headers': {'apns-priority': '10'},
          'payload': {
            'aps': {
              'alert': {'title': title, 'body': body},
              'sound': 'default',
              'badge': 1,
            },
          },
        },
      };

      if (data != null && data.isNotEmpty) {
        messagePayload['data'] = data;
      }

      if (topic != null && topic.isNotEmpty) {
        final cleanTopic = topic.replaceFirst('/topics/', '');
        messagePayload['topic'] = cleanTopic;
      } else if (targetToken != null && targetToken.isNotEmpty) {
        messagePayload['token'] = targetToken;
      }

      final bodyJson = jsonEncode({'message': messagePayload});

      final response = await client.post(
        Uri.parse(_fcmEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: bodyJson,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          'FCM Message sent successfully to ${topic ?? "token"}: [${response.statusCode}]',
        );
        return true;
      } else {
        debugPrint(
          'FCM Message failed to send: [${response.statusCode}] ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error sending FCM push notification: $e');
      return false;
    }
  }

  /// ⚽ إشعار فتح حجز مباراة جديدة لجميع الأصدقاء
  Future<bool> sendMatchCreatedNotification({
    required String matchId,
    required String matchTitle,
    required String matchDate,
    required String matchTime,
    required String stadium,
  }) async {
    return sendNotification(
      topic: 'kickoff_all',
      title: '⚽ حجز مباراة جديدة: $matchTitle',
      body:
          'الموعد: $matchDate الساعة $matchTime في $stadium. بادر بحجز مكانك!',
      data: {
        'type': 'match',
        'targetId': matchId,
        'route': '/matches/$matchId',
      },
    );
  }

  /// 📋 إشعار نشر وتوزيع الفرق الثلاثة
  Future<bool> sendTeamsPublishedNotification({
    required String matchId,
    required String matchTitle,
  }) async {
    return sendNotification(
      topic: 'kickoff_all',
      title: '📋 تم إعلان تشكيلات الفرق الثلاثة!',
      body:
          'تم توزيع اللاعبين لمباراة $matchTitle بصورة متوازنة. تفقد تشكيلة فريقك الآن.',
      data: {
        'type': 'teams',
        'targetId': matchId,
        'route': '/matches/$matchId',
      },
    );
  }

  /// 🟢 إشعار تصعيد لاعب من قائمة الانتظار إلى التشكيلة الأساسية
  Future<bool> sendWaitlistPromotedNotification({
    String? playerFcmToken,
    required String playerName,
    required String matchTitle,
    required String matchId,
  }) async {
    return sendNotification(
      targetToken: playerFcmToken,
      topic: playerFcmToken == null ? 'kickoff_all' : null,
      title: '🎉 تأكيد مشاركتك في المباراة!',
      body:
          'مبروك يا كابتن $playerName! تم تصعيدك من قائمة الانتظار لتلعب في مباراة $matchTitle.',
      data: {
        'type': 'promotion',
        'targetId': matchId,
        'route': '/matches/$matchId',
      },
    );
  }

  /// 🗳️ إشعار استطلاع رأي جديد للتصويت
  Future<bool> sendPollCreatedNotification({
    required String pollId,
    required String question,
  }) async {
    return sendNotification(
      topic: 'kickoff_all',
      title: '🗳️ استطلاع جديد بانتظار تصويتك!',
      body: question,
      data: {'type': 'poll', 'targetId': pollId, 'route': '/polls'},
    );
  }

  /// 📢 إشعار وتنبيه إداري عام من منظم المجموعة
  Future<bool> sendAdminBroadcast({
    required String title,
    required String message,
  }) async {
    return sendNotification(
      topic: 'kickoff_all',
      title: '📢 تنبيه من الكابتن: $title',
      body: message,
      data: {'type': 'announcement'},
    );
  }

  /// ⚠️ إشعار اعتذار وانسحاب لاعب من المباراة إلى الكابتن
  Future<bool> sendPlayerWithdrawalNotification({
    required String playerName,
    required String matchTitle,
    required String reason,
    String? customNote,
  }) async {
    final note = customNote != null && customNote.isNotEmpty ? ' ($customNote)' : '';
    return sendNotification(
      topic: 'kickoff_all',
      title: 'اعتذار لاعب عن المباراة ⚠️',
      body: 'اعتذر اللاعب $playerName عن حضور $matchTitle.\nالسبب: $reason$note',
      data: {'type': 'withdrawal'},
    );
  }

  /// 🏆 إشعار رسمي بصدور وتثبيت نتائج المباراة والفريق الفائز
  Future<bool> sendMatchResultsPublishedNotification({
    required String matchTitle,
    required String winningTeam,
    required String? motmName,
  }) async {
    final motmPart = motmName != null && motmName.isNotEmpty
        ? ' • رجل المباراة: $motmName ⭐'
        : '';
    return sendNotification(
      topic: 'kickoff_all',
      title: '🏆 صدرت نتيجة المباراة رسمياً!',
      body: 'تهانينا لـ $winningTeam بالصدارة في $matchTitle$motmPart',
      data: {'type': 'match_result'},
    );
  }

  /// ⏰ إشعار تذكيري قبل فتح حجز مقاعد المباراة بـ 5 دقائق
  Future<bool> sendRegistrationOpeningSoonReminder({
    required String matchTitle,
    required String timeStr,
  }) async {
    return sendNotification(
      topic: 'kickoff_all',
      title: '⏰ استعد! يفتح حجز المباراة بعد 5 دقائق',
      body: 'سيتم فتح حجز مقاعد $matchTitle في تمام $timeStr. كن أول الحاجزين! ⚽',
      data: {'type': 'registration_reminder'},
    );
  }
}
