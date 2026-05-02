import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class GetAuthState {
  final AuthRepository repository;

  GetAuthState(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}
