import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/config/firebase_admin_credentials.dart';
import 'package:football_reservation/core/services/firebase_notification_sender_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('FirebaseAdminCredentials & FcmSender Tests', () {
    test('Credentials map contains required service account fields', () {
      final creds = FirebaseAdminCredentials.serviceAccountMap;
      expect(creds['type'], equals('service_account'));
      expect(creds['project_id'], equals('football-app-a6063'));
      expect(creds['client_email'], contains('football-app-a6063'));
      expect(creds['private_key'], contains('BEGIN PRIVATE KEY'));
    });

    test(
      'sendNotification sends properly formatted FCM HTTP v1 payload to topic',
      () async {
        String? capturedEndpoint;
        Map<String, dynamic>? capturedBody;

        final mockClient = MockClient((request) async {
          capturedEndpoint = request.url.toString();
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'name': 'projects/football-app-a6063/messages/12345'}),
            200,
          );
        });

        final senderService = FirebaseNotificationSenderService(
          httpClient: mockClient,
        );

        final success = await senderService.sendNotification(
          topic: 'kickoff_all',
          title: '⚽ حجز جديد',
          body: 'تم فتح حجز الجمعة!',
          data: {'type': 'match', 'targetId': 'm-1'},
        );

        expect(success, isTrue);
        expect(capturedEndpoint, contains('football-app-a6063/messages:send'));
        expect(capturedBody, isNotNull);
        final message = capturedBody!['message'] as Map<String, dynamic>;
        expect(message['topic'], equals('kickoff_all'));
        expect(message['notification']['title'], equals('⚽ حجز جديد'));
        expect(message['notification']['body'], equals('تم فتح حجز الجمعة!'));
        expect(message['data']['targetId'], equals('m-1'));
        expect(
          message['android']['notification']['channel_id'],
          equals('kickoff_high_importance_channel'),
        );
      },
    );

    test('sendNotification sends properly to individual targetToken', () async {
      Map<String, dynamic>? capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'name': 'projects/football-app-a6063/messages/999'}),
          200,
        );
      });

      final senderService = FirebaseNotificationSenderService(
        httpClient: mockClient,
      );

      final success = await senderService.sendNotification(
        targetToken: 'device_token_xyz_123',
        title: 'تأكيد الحجز',
        body: 'تم تأكيد حجزك في المباراة',
      );

      expect(success, isTrue);
      final message = capturedBody!['message'] as Map<String, dynamic>;
      expect(message['token'], equals('device_token_xyz_123'));
      expect(message.containsKey('topic'), isFalse);
    });

    test(
      'sendMatchCreatedNotification formats match parameters correctly',
      () async {
        Map<String, dynamic>? capturedBody;

        final mockClient = MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        });

        final senderService = FirebaseNotificationSenderService(
          httpClient: mockClient,
        );

        await senderService.sendMatchCreatedNotification(
          matchId: 'match-101',
          matchTitle: 'كلاسيكو الجمعة',
          matchDate: '2026-11-14',
          matchTime: '08:00 م',
          stadium: 'ملعب السد',
        );

        final message = capturedBody!['message'] as Map<String, dynamic>;
        expect(message['notification']['title'], contains('كلاسيكو الجمعة'));
        expect(message['notification']['body'], contains('ملعب السد'));
        expect(message['data']['targetId'], equals('match-101'));
      },
    );

    test(
      'sendTeamsPublishedNotification formats teams alert properly',
      () async {
        Map<String, dynamic>? capturedBody;

        final mockClient = MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        });

        final senderService = FirebaseNotificationSenderService(
          httpClient: mockClient,
        );

        await senderService.sendTeamsPublishedNotification(
          matchId: 'match-202',
          matchTitle: 'مباراة الخميس',
        );

        final message = capturedBody!['message'] as Map<String, dynamic>;
        expect(
          message['notification']['title'],
          contains('تشكيلات الفرق الثلاثة'),
        );
        expect(message['data']['type'], equals('teams'));
      },
    );

    test('sendWaitlistPromotedNotification notifies promoted player', () async {
      Map<String, dynamic>? capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 200);
      });

      final senderService = FirebaseNotificationSenderService(
        httpClient: mockClient,
      );

      await senderService.sendWaitlistPromotedNotification(
        playerName: 'ياسر',
        matchTitle: 'مباراة الأسبوع',
        matchId: 'match-303',
      );

      final message = capturedBody!['message'] as Map<String, dynamic>;
      expect(message['notification']['title'], contains('تأكيد مشاركتك'));
      expect(message['notification']['body'], contains('ياسر'));
      expect(message['data']['type'], equals('promotion'));
    });

    test('sendAdminBroadcast sends message with announcement type', () async {
      Map<String, dynamic>? capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 200);
      });

      final senderService = FirebaseNotificationSenderService(
        httpClient: mockClient,
      );

      final result = await senderService.sendAdminBroadcast(
        title: 'تأكيد الحضور',
        message: 'يا شباب الرجاء التواجد مبكراً',
      );

      expect(result, isTrue);
      final message = capturedBody!['message'] as Map<String, dynamic>;
      expect(message['notification']['title'], contains('تأكيد الحضور'));
      expect(
        message['notification']['body'],
        equals('يا شباب الرجاء التواجد مبكراً'),
      );
      expect(message['data']['type'], equals('announcement'));
    });

    test('sendNotification returns false on HTTP error status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Unauthorized"}', 401);
      });

      final senderService = FirebaseNotificationSenderService(
        httpClient: mockClient,
      );

      final result = await senderService.sendNotification(
        topic: 'kickoff_all',
        title: 'Test',
        body: 'Test',
      );

      expect(result, isFalse);
    });
  });
}
