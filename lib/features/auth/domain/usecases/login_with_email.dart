import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<Either<String, UserEntity>> call({required String email, required String password}) {
    return repository.loginWithEmail(email: email, password: password);
  }
}
