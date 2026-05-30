import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<String, UserEntity>> loginWithEmail({required String email, required String password});
  Future<Either<String, UserEntity>> registerWithEmail({required String name, required String email, required String password});
  Future<Either<String, void>> sendPasswordResetEmail({required String email});
  Future<void> logout();
  Future<void> updateFCMToken(String uid, String token);
  Future<Either<String, void>> deleteAccount({required String password});
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerified();
}
