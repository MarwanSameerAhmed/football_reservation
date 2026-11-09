import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_role.dart';

/// Pure domain entity representing an authenticated user in Kickoff.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isEmailVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    required this.createdAt,
  });

  bool get isAdmin => role.isAdmin;
  bool get isPlayer => role.isPlayer;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    String? photoUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    role,
    photoUrl,
    phoneNumber,
    isEmailVerified,
    createdAt,
  ];
}
