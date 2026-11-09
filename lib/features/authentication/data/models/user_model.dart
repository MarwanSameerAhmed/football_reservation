import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/user_role.dart';
import '../../domain/entities/user_entity.dart';

/// Data Transfer Object (DTO) for [UserEntity].
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.role,
    super.photoUrl,
    super.phoneNumber,
    super.isEmailVerified = false,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.player,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
                ? (json['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      role: entity.role,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
    );
  }
}
