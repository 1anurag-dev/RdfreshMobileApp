import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String status;
  final String createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'user',
    this.status = 'approved',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, role, status, createdAt];
}
