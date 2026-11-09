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

  // Live Firebase toggle: pass --dart-define=USE_FIREBASE=true to connect live to Firestore/Auth
  const bool useFirebaseEnv = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: false,
  );
  await setupLocator(useFirebase: useFirebaseEnv && firebaseInitialized);

  // Initialize Push Notification Service (FCM) when Firebase is initialized
  if (firebaseInitialized) {
    try {
      await sl<PushNotificationService>().initialize();
    } catch (e) {
      debugPrint('PushNotificationService init note: $e');
    }
  }

  runApp(const KickoffApp());
}
