import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/app/app.dart';
import 'package:football_reservation/core/di/injection_container.dart';
import 'package:football_reservation/core/presentation/widgets/kickoff_widgets.dart';
import 'package:football_reservation/features/authentication/data/datasources/auth_remote_data_source.dart';

void main() {
  setUpAll(() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      await setupLocator();
    }
  });

  testWidgets('Kickoff smoke test and responsive shell verification', (
    WidgetTester tester,
  ) async {
    // Pump KickoffApp
    await tester.pumpWidget(const KickoffApp());
    await tester.pumpAndSettle();

    // Verify HomePage renders
    expect(find.byType(KickoffResponsiveShell), findsWidgets);
    expect(find.text('مروان سمير'), findsOneWidget);
    expect(find.byType(KickoffBadge), findsWidgets);
    expect(find.byType(KickoffSearchField), findsOneWidget);
    expect(find.byType(KickoffHeroCard), findsOneWidget);
  });
}
