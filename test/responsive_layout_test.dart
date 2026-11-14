import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/app/app.dart';
import 'package:football_reservation/app/router/app_router.dart';
import 'package:football_reservation/core/di/injection_container.dart';
import 'package:football_reservation/core/presentation/widgets/kickoff_widgets.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:football_reservation/features/players/presentation/widgets/add_player_dialog.dart';

void main() {
  setUpAll(() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      await setupLocator(seedDemoData: true);
    }
  });

  setUp(() {
    AppRouter.router.go('/');
  });

  group('Responsive Layout & Screen Form Factors Verification', () {
    testWidgets('Renders perfectly on Compact Phone (320x568 - iPhone SE)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const KickoffApp());
      await tester.pumpAndSettle();

      expect(find.byType(KickoffResponsiveShell), findsWidgets);
      expect(find.byType(KickoffBottomNavBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Renders perfectly on Mainstream Phone (390x844 - iPhone 14/15)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390 * 3.0, 844 * 3.0);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        expect(find.byType(KickoffHeroCard), findsOneWidget);
        final error = tester.takeException();
        if (error != null) {
          // ignore: avoid_print
          print('DIAGNOSTICS: $error');
        }
        expect(error, isNull);
      },
    );

    testWidgets(
      'Renders perfectly on Mobile-Web Desktop (1200x800 - Centered Container)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        // Confirms maximum content width shell prevents stretching across large screens
        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        final error = tester.takeException();
        if (error != null) {
          // ignore: avoid_print
          print('DIAGNOSTICS: $error');
        }
        expect(error, isNull);
      },
    );

    testWidgets(
      'Navigates and renders NotificationsPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        // Tap notifications button in top bar
        final notifBell = find.byTooltip('التنبيهات');
        expect(notifBell, findsOneWidget);
        await tester.tap(notifBell);
        await tester.pumpAndSettle();

        final err = tester.takeException();
        if (err is FlutterError) {
          for (final d in err.diagnostics) {
            // ignore: avoid_print
            print('DIAG: ${d.toStringDeep()}');
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'Navigates and renders PollsPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        // Navigate to polls page
        AppRouter.router.push('/polls');
        await tester.pumpAndSettle();

        final err = tester.takeException();
        if (err != null) {
          // ignore: avoid_print
          print('FULL POLLS ERROR:\n$err');
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'Navigates and renders StatisticsPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        // Navigate to statistics page
        AppRouter.router.go('/statistics');
        await tester.pumpAndSettle();

        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Navigates and renders MatchDetailsPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/match-details');
        await tester.pumpAndSettle();

        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        final err = tester.takeException();
        if (err is FlutterError) {
          // ignore: avoid_print
          print(
            'PLAYER_DETAILS DIAGNOSTICS:\n${err.diagnostics.map((d) => d.toString()).join("\n")}',
          );
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'Navigates and renders ReserveSpotPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/reserve');
        await tester.pumpAndSettle();

        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        final err = tester.takeException();
        if (err is FlutterError) {
          // ignore: avoid_print
          print(
            'PLAYER_DETAILS DIAGNOSTICS:\n${err.diagnostics.map((d) => d.toString()).join("\n")}',
          );
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'Navigates and renders PlayersListPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/players');
        await tester.pumpAndSettle();

        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        final err = tester.takeException();
        if (err is FlutterError) {
          // ignore: avoid_print
          print(
            'PLAYER_DETAILS DIAGNOSTICS:\n${err.diagnostics.map((d) => d.toString()).join("\n")}',
          );
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'Navigates and renders PlayerDetailsPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/player-details/p1');
        await tester.pumpAndSettle();

        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        final err = tester.takeException();
        if (err is FlutterError) {
          for (final d in err.diagnostics) {
            // ignore: avoid_print
            print('DIAG: ${d.toStringDeep()}');
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'PlayerDetailsPage renders visible body & skills breakdown in regular Player mode',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390 * 3.0, 844 * 3.0);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        // Switch from Admin to regular Player mode if currently Admin
        final switchToPlayerFinder = find.text('تجربة كـ لاعب');
        if (switchToPlayerFinder.evaluate().isNotEmpty) {
          await tester.tap(switchToPlayerFinder);
          await tester.pumpAndSettle();
        }

        AppRouter.router.go('/player-details/p1');
        await tester.pumpAndSettle();

        final listFinder = find.byType(ListView);
        expect(listFinder, findsOneWidget);
        expect(tester.getSize(listFinder).height, greaterThan(200));
        expect(find.text('المباريات'), findsOneWidget);
        expect(
          find.text('تقييمات اللاعب معتمدة ومحدثة من قبل كابتن المجموعة.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        // Restore Admin mode for test isolation
        AppRouter.router.go('/');
        await tester.pumpAndSettle();
        final switchToAdminFinder = find.text('تفعيل الكابتن');
        if (switchToAdminFinder.evaluate().isNotEmpty) {
          await tester.tap(switchToAdminFinder);
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Navigates and renders TeamGeneratorPage on Compact Phone without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/team-generator');
        await tester.pumpAndSettle();

        expect(find.byType(KickoffResponsiveShell), findsWidgets);
        final err = tester.takeException();
        if (err is FlutterError) {
          // ignore: avoid_print
          print(
            'PLAYER_DETAILS DIAGNOSTICS:\n${err.diagnostics.map((d) => d.toString()).join("\n")}',
          );
        }
        expect(err, isNull);
      },
    );

    testWidgets('Toggles theme between Light and Dark mode seamlessly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const KickoffApp());
      await tester.pumpAndSettle();

      // Find theme toggle button and tap
      final themeButton = find.byTooltip('تغيير المظهر');
      expect(themeButton, findsOneWidget);

      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      final error = tester.takeException();
      if (error != null) {
        // ignore: avoid_print
        print('DIAGNOSTICS: $error');
      }
      expect(error, isNull);
    });

    testWidgets(
      'PlayerDetailsPage allows photo editing ONLY for the player own profile',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390 * 3.0, 844 * 3.0);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        // Own profile (p1 -> Marwan Sameer / admin_1): camera badge visible
        AppRouter.router.go('/player-details/p1');
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

        // Another player's profile (p2 -> Fahad / u2): camera badge hidden
        AppRouter.router.go('/player-details/p2');
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AddPlayerDialog defaults country code picker to Yemen (+967) without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/');
        await tester.pumpAndSettle();

        // Ensure Admin quick control card is visible
        final addPlayerCard = find.text('إضافة لاعب');
        expect(addPlayerCard, findsOneWidget);
        await tester.tap(addPlayerCard);
        await tester.pumpAndSettle();

        expect(find.text('🇾🇪 +967'), findsOneWidget);
        expect(find.text('اختيار من جهات الاتصال'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HomePage toggles Captain permissions when switching between Player and Captain mode',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390 * 3.0, 844 * 3.0);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const KickoffApp());
        await tester.pumpAndSettle();

        AppRouter.router.go('/');
        await tester.pumpAndSettle();

        // Starts in Captain mode with full permissions visible
        expect(find.text('مسؤول المجموعة (الكابتن)'), findsOneWidget);
        expect(find.text('لوحة تحكم الكابتن'), findsOneWidget);
        expect(find.text('حجز مباراة'), findsOneWidget);

        // Switch to Player mode
        await tester.tap(find.text('تجربة كـ لاعب'));
        await tester.pumpAndSettle();

        expect(find.text('لاعب في المجموعة'), findsOneWidget);
        expect(find.text('لوحة تحكم الكابتن'), findsNothing);

        // Switch back to Captain mode and verify permissions return
        await tester.tap(find.text('تفعيل الكابتن'));
        await tester.pumpAndSettle();

        expect(find.text('مسؤول المجموعة (الكابتن)'), findsOneWidget);
        expect(find.text('لوحة تحكم الكابتن'), findsOneWidget);
        expect(find.text('حجز مباراة'), findsOneWidget);
        expect(find.text('إضافة لاعب'), findsOneWidget);
        expect(find.text('طرح تصويت'), findsOneWidget);
        expect(find.text('توزيع الفرق'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('AddPlayerDialog.parseContactPhone', () {
    test('parses international +967 format correctly', () {
      final parsed = AddPlayerDialog.parseContactPhone('+967 771 234 567');
      expect(parsed.countryCode, '+967');
      expect(parsed.localNumber, '771234567');
    });

    test('parses 00-prefixed international code (00966) correctly', () {
      final parsed = AddPlayerDialog.parseContactPhone('00966 50 123 4567');
      expect(parsed.countryCode, '+966');
      expect(parsed.localNumber, '501234567');
    });

    test('normalizes Arabic numerals and strips leading local zero', () {
      final parsed = AddPlayerDialog.parseContactPhone('٠٧٧١٢٣٤٥٦٧');
      expect(parsed.countryCode, '+967');
      expect(parsed.localNumber, '771234567');
    });

    test('uses fallbackCountryCode for plain local numbers', () {
      final parsed = AddPlayerDialog.parseContactPhone(
        '770001122',
        fallbackCountryCode: '+967',
      );
      expect(parsed.countryCode, '+967');
      expect(parsed.localNumber, '770001122');
    });
  });
}
