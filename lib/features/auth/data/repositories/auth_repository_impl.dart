import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/notification/data/services/secure_notification_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureNotificationService secureNotificationService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureNotificationService,
  });

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<Either<String, UserEntity>> loginWithEmail({required String email, required String password}) async {
    try {
      final user = await remoteDataSource.loginWithEmail(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } on UserUnapprovedException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Something went wrong. Please try again.');
    }
  }

  @override
  Future<Either<String, UserEntity>> registerWithEmail({required String name, required String email, required String password}) async {
    try {
      final user = await remoteDataSource.registerWithEmail(name: name, email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left('Something went wrong. Please try again.');
    }
  }

  @override
  Future<Either<String, void>> sendPasswordResetEmail({required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left('Failed to send reset email. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<void> updateFCMToken(String uid, String token) async {
    await secureNotificationService.syncFCMToken(uid);
  }
  
  @override
  Future<Either<String, void>> deleteAccount({required String password}) async {
    try {
      await remoteDataSource.deleteAccount(password: password);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left('Failed to delete account. Please try again.');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await remoteDataSource.sendEmailVerification();
  }

  @override
  Future<bool> checkEmailVerified() async {
    return remoteDataSource.checkEmailVerified();
  }

  String _mapAuthException(AuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'The email or password is incorrect, or this account no longer exists. Please reset the password or check the Firebase user.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'This account has been disabled in Firebase Authentication.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is strictly invalid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Wait a few minutes, then try again or reset the password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password login is disabled in Firebase Authentication.';
      case 'invalid-user-token':
      case 'user-token-expired':
        return 'Your session expired. Please sign in again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
