import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class DeleteAccountRequested extends AuthEvent {
  final String password;

  const DeleteAccountRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

class SendEmailVerificationRequested extends AuthEvent {}

class CheckEmailVerificationRequested extends AuthEvent {}
