import 'package:equatable/equatable.dart';

/// Base Failure class for domain layer error representation.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'حدث خطأ في الخادم السحابي',
    super.code,
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'فشل في عملية تسجيل الدخول أو الصلاحيات',
    super.code,
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'البيانات المدخلة غير صحيحة',
    super.code,
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'العنصر المطلوب غير موجود',
    super.code,
  ]);
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([
    super.message = 'ليس لديك الصلاحية لتنفيذ هذا الإجراء',
    super.code,
  ]);
}
