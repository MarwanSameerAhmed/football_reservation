import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../models/user_model.dart';

/// Contract interface for remote authentication data source.
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    UserRole role = UserRole.player,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

/// Production implementation connecting directly to Firebase Auth & Cloud Firestore.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('فشل في تسجيل الدخول');
      }

      final doc = await _usersCollection.doc(firebaseUser.uid).get();
      if (!doc.exists) {
        // Fallback user model if Firestore doc hasn't synced
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          displayName: firebaseUser.displayName ?? email.split('@').first,
          role: UserRole.player,
          createdAt: DateTime.now(),
        );
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    UserRole role = UserRole.player,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('فشل في إنشاء الحساب');
      }

      // Update Firebase Auth display name
      await firebaseUser.updateDisplayName(displayName);

      final userModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Persist user record in Firestore
      await _usersCollection.doc(firebaseUser.uid).set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _usersCollection.doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        role: UserRole.player,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final doc = await _usersCollection.doc(firebaseUser.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          role: UserRole.player,
          createdAt: DateTime.now(),
        );
      } catch (_) {
        return null;
      }
    });
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('البريد الإلكتروني غير مسجل');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthException('كلمة المرور أو البريد الإلكتروني غير صحيح');
      case 'email-already-in-use':
        return const AuthException('البريد الإلكتروني مسجل بالفعل');
      case 'invalid-email':
        return const AuthException('صيغة البريد الإلكتروني غير صحيحة');
      case 'weak-password':
        return const AuthException('كلمة المرور ضعيفة جداً');
      case 'user-disabled':
        return const AuthException('هذا الحساب تم تعطيله، تواصل مع المسؤول');
      case 'network-request-failed':
        return const AuthException(
          'تعذر الاتصال بالخادم، تحقق من اتصال الإنترنت',
        );
      default:
        return AuthException(e.message ?? 'حدث خطأ في عملية المصادقة');
    }
  }
}

/// In-memory mock data source for testing and immediate offline development.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final Map<String, UserModel> _users = {
    'marwan@kickoff.com': UserModel(
      id: 'admin_1',
      email: 'marwan@kickoff.com',
      displayName: 'مروان سمير',
      role: UserRole.admin,
      createdAt: DateTime(2026, 1, 1),
    ),
    'player@kickoff.com': UserModel(
      id: 'player_1',
      email: 'player@kickoff.com',
      displayName: 'أحمد علي',
      role: UserRole.player,
      createdAt: DateTime(2026, 2, 1),
    ),
  };

  final _authStreamController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  final Duration delay;

  MockAuthRemoteDataSource({
    UserModel? initialUser,
    this.delay = Duration.zero,
    bool seedDefault = false,
  }) {
    _currentUser = initialUser ?? (seedDefault ? _users['marwan@kickoff.com'] : null);
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final normalized = email.toLowerCase().trim();
    if (_users.containsKey(normalized)) {
      _currentUser = _users[normalized];
      _authStreamController.add(_currentUser);
      return _currentUser!;
    }

    // Match by phone number across all users
    final cleanLookup = normalized.split('@').first.replaceAll(RegExp(r'[\s\-\+]'), '');
    final phoneMatch = _users.values.cast<UserModel?>().firstWhere(
          (u) {
            if (u == null || u.phoneNumber == null) return false;
            final cleanUserPhone =
                u.phoneNumber!.replaceAll(RegExp(r'[\s\-\+]'), '');
            return cleanUserPhone == cleanLookup;
          },
          orElse: () => null,
        );
    if (phoneMatch != null) {
      _currentUser = phoneMatch;
      _authStreamController.add(_currentUser);
      return phoneMatch;
    }

    // Automatically create if not found in mock for smooth pairing demo
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: normalized,
      displayName: normalized.split('@').first,
      role: UserRole.player,
      createdAt: DateTime.now(),
    );
    _users[normalized] = newUser;
    _currentUser = newUser;
    _authStreamController.add(_currentUser);
    return newUser;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    UserRole role = UserRole.player,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final normalized = email.toLowerCase().trim();
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: normalized,
      displayName: displayName,
      role: role,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );
    _users[normalized] = newUser;
    _currentUser = newUser;
    _authStreamController.add(_currentUser);
    return newUser;
  }

  @override
  Future<void> signOut() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _currentUser = null;
    _authStreamController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;
}
