import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/app/app.dart';
import 'package:football_reservation/app/router/app_router.dart';
import 'package:football_reservation/core/di/injection_container.dart';
import 'package:football_reservation/core/presentation/widgets/kickoff_widgets.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';

void main() {
  setUpAll(() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      await setupLocator();
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

        expect(tester.takeException(), isNull);
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

        // Tap polls item in bottom nav
        final pollsNav = find.text('التصويت');
        expect(pollsNav, findsOneWidget);
        await tester.tap(pollsNav);
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
        final statsErr = tester.takeException();
        if (statsErr != null) {
          // ignore: avoid_print
          print('STATS DIAGNOSTICS: $statsErr');
        }
        expect(statsErr, isNull);
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
        expect(tester.takeException(), isNull);
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
        print(
          'DIAGNOSTICS:\n${(error as FlutterError).diagnostics.map((d) => d.toString()).join('\n')}',
        );
      }
      expect(error, isNull);
    });
  });
}
