import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_reservation/app/theme/app_colors.dart';
import 'package:football_reservation/core/extensions/context_extensions.dart';
import 'package:football_reservation/core/presentation/widgets/kickoff_toast.dart';

void main() {
  Widget buildTestHost({required void Function(BuildContext) onTrigger}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => onTrigger(context),
              child: const Text('Trigger Toast'),
            );
          },
        ),
      ),
    );
  }

  group('KickoffToast Widget & Extension Tests', () {
    testWidgets('Renders success floating pill toast with checkmark icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestHost(
          onTrigger: (context) {
            context.showSuccessToast('تم إنزال اللاعب مروان سمير إلى قائمة الانتظار ⬇️');
          },
        ),
      );

      // Tap trigger button
      await tester.tap(find.text('Trigger Toast'));
      await tester.pump(); // Start SnackBar animation
      await tester.pump(const Duration(milliseconds: 300)); // Animation settling

      // Verify KickoffToastWidget renders
      expect(find.byType(KickoffToastWidget), findsOneWidget);
      expect(
        find.text('تم إنزال اللاعب مروان سمير إلى قائمة الانتظار ⬇️'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify executive squircle toast decoration
      final containerFinder = find.descendant(
        of: find.byType(KickoffToastWidget),
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.darkSlate));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
    });

    testWidgets('Renders error toast with close icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestHost(
          onTrigger: (context) {
            context.showErrorToast('حدث خطأ في الاتصال بالخادم');
          },
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(KickoffToastWidget), findsOneWidget);
      expect(find.text('حدث خطأ في الاتصال بالخادم'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('Renders warning and info toasts with correct icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestHost(
          onTrigger: (context) {
            context.showWarningToast('تنبيه: اقترب موعد إغلاق التسجيل');
          },
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
      expect(find.text('تنبيه: اقترب موعد إغلاق التسجيل'), findsOneWidget);
    });
  });
}

