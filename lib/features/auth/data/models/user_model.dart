import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role = 'user',
    super.status = 'approved',
    required super.createdAt,
  });

  factory UserModel.fromFirebase(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      role: 'user',
      status: 'approved',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'approved',
      createdAt: data['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
