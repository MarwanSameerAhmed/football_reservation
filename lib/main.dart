import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/services/push_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization status: $e');
  }

  // Live Firebase toggle: defaults to true for production launch.
  const bool useFirebaseEnv = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: true,
  );
  // Open with a clean slate (zero demo data) ready for real testing
  await setupLocator(
    useFirebase: useFirebaseEnv && firebaseInitialized,
    seedDemoData: false,
  );

  // Launch UI immediately without blocking on FCM permission/topic network I/O
  runApp(const KickoffApp());

  if (firebaseInitialized) {
    unawaited(
      sl<PushNotificationService>().initialize().catchError((Object e) {
        debugPrint('PushNotificationService init note: $e');
      }),
    );
  }
}
