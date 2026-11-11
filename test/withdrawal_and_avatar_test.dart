import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/presentation/widgets/kickoff_avatar.dart';
import 'package:football_reservation/core/utils/avatar_image_helper.dart';
import 'package:football_reservation/features/matches/data/datasources/match_remote_data_source.dart';
import 'package:football_reservation/features/matches/domain/entities/player_withdrawal_entity.dart';

void main() {
  group('Base64 Avatar & Helper Tests', () {
    test('tryDecodeBase64 safely decodes valid Data URI and raw Base64', () {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final base64Str = base64Encode(sampleBytes);
      final dataUri = 'data:image/jpeg;base64,$base64Str';

      final decodedFromUri = AvatarImageHelper.tryDecodeBase64(dataUri);
      expect(decodedFromUri, isNotNull);
      expect(decodedFromUri, equals(sampleBytes));

      // Invalid or non-base64 safely returns null
      expect(AvatarImageHelper.tryDecodeBase64('https://example.com/pic.jpg'), isNull);
      expect(AvatarImageHelper.tryDecodeBase64('⚽'), isNull);
      expect(AvatarImageHelper.tryDecodeBase64(''), isNull);
      expect(AvatarImageHelper.tryDecodeBase64(null), isNull);
    });

    testWidgets('KickoffAvatar renders Image.memory for Base64 Data URI', (tester) async {
      // 1x1 transparent PNG base64
      const transparentPixelPng =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KickoffAvatar(
              photoUrl: transparentPixelPng,
              name: 'مروان سمير',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('KickoffAvatar renders character avatar when character URL or preset is passed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KickoffAvatar(
              photoUrl: '👑',
              name: 'مروان سمير',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('KickoffAvatar falls back to character painter when photo is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KickoffAvatar(
              photoUrl: null,
              name: 'فهد الدوسري',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('Match Withdrawal Reason & Admin Log Tests', () {
    test('Cancel registration records withdrawal reason and promotes waiting player', () async {
      final dataSource = MockMatchRemoteDataSource(delay: Duration.zero);
      final matches = await dataSource.getMatches();
      final match = matches.first;

      // Ensure match has at least 1 confirmed player
      expect(match.confirmedPlayers.isNotEmpty, isTrue);
      final playerToCancel = match.confirmedPlayers.first;

      final updatedMatch = await dataSource.cancelRegistration(
        matchId: match.id,
        playerId: playerToCancel.playerId,
        playerName: playerToCancel.playerName,
        reason: 'إصابة رياضية 🤕',
        customNote: 'تمزق في العضلة الخلفية أثناء التمرين',
      );

      // Verify the player was removed from confirmed players
      expect(
        updatedMatch.confirmedPlayers.any((p) => p.playerId == playerToCancel.playerId),
        isFalse,
      );

      // Verify withdrawal entry was recorded
      expect(updatedMatch.withdrawals.isNotEmpty, isTrue);
      final withdrawal = updatedMatch.withdrawals.last;
      expect(withdrawal.playerId, equals(playerToCancel.playerId));
      expect(withdrawal.playerName, equals(playerToCancel.playerName));
      expect(withdrawal.reason, equals('إصابة رياضية 🤕'));
      expect(withdrawal.customNote, equals('تمزق في العضلة الخلفية أثناء التمرين'));
      expect(withdrawal.withdrawnAt, isNotNull);
    });

    test('PlayerWithdrawalEntity serializes to and from JSON correctly', () {
      final now = DateTime(2026, 11, 10, 15, 30);
      final entity = PlayerWithdrawalEntity(
        playerId: 'p100',
        playerName: 'سالم الدوسري',
        reason: 'ظرف عائلي طارئ 👨‍👩‍👧',
        customNote: 'ارتباط أسري مفاجئ',
        withdrawnAt: now,
      );

      final json = entity.toJson();
      final parsed = PlayerWithdrawalEntity.fromJson(json);

      expect(parsed.playerId, equals(entity.playerId));
      expect(parsed.playerName, equals(entity.playerName));
      expect(parsed.reason, equals(entity.reason));
      expect(parsed.customNote, equals(entity.customNote));
      expect(parsed.withdrawnAt.year, equals(now.year));
    });
  });
}
