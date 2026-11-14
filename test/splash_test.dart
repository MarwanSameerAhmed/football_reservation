import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/app/app.dart';
import 'package:football_reservation/app/router/app_router.dart';
import 'package:football_reservation/app/theme/app_colors.dart';
import 'package:football_reservation/core/di/injection_container.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:football_reservation/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:football_reservation/features/splash/presentation/pages/video_splash_page.dart';

void main() {
  setUpAll(() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      await setupLocator(seedDemoData: true);
    }
  });

  testWidgets(
    'VideoSplashPage renders with exact app canvas background without skip control',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: VideoSplashPage()));

      // Verify Scaffold has the exact color matching app canvas
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppColors.canvasLight));

      // Skip button has been removed per design request
      expect(find.text('تخطي'), findsNothing);
    },
  );

  testWidgets(
    'Unauthenticated startup routes cleanly from VideoSplashPage to SignInPage',
    (WidgetTester tester) async {
      await setupLocator(seedDemoData: false);
      addTearDown(() => setupLocator(seedDemoData: true));

      AppRouter.router.go('/splash');
      await tester.pumpWidget(const KickoffApp());
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('تفعيل الكابتن'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
