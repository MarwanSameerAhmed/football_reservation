import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/core/di/injection_container.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:football_reservation/features/splash/presentation/pages/video_splash_page.dart';

void main() {
  setUpAll(() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      await setupLocator();
    }
  });

  testWidgets(
    'VideoSplashPage renders with exact #F2F2E7 canvas and skip control',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: VideoSplashPage()));

      // Verify Scaffold has the exact color matching native launch screen
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFFF2F2E7)));

      // Verify Skip button exists with Arabic label
      expect(find.text('تخطي'), findsOneWidget);
      expect(find.byIcon(Icons.fast_forward_rounded), findsOneWidget);
    },
  );
}
