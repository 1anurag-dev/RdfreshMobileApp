import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<Either<String, UserEntity>> call({required String name, required String email, required String password}) {
    return repository.registerWithEmail(name: name, email: email, password: password);
  }
}
