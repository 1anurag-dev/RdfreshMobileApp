import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_auth_state.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_with_email.dart';
import 'package:rdfresh/features/auth/domain/repositories/auth_repository.dart';
import 'package:rdfresh/features/auth/domain/entities/user_entity.dart';
import 'package:rdfresh/core/notification/data/services/secure_notification_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final RegisterWithEmail registerWithEmail;
  final Logout logout;
  final GetAuthState getAuthState;
  final AuthRepository authRepository;
  final SecureNotificationService secureNotificationService;

  AuthBloc({
    required this.loginWithEmail,
    required this.registerWithEmail,
    required this.logout,
    required this.getAuthState,
    required this.authRepository,
    required this.secureNotificationService,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach(
      getAuthState(),
      onData: (user) {
        if (user != null) {
          secureNotificationService.syncFCMToken(user.id);
          return Authenticated(user: user);
        } else {
          return Unauthenticated();
        }
      },
      onError: (error, _) {
        return const AuthError(
          message: 'Failed to verify authentication state',
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginWithEmail(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure));
      },
      (user) async {
        try {
          await secureNotificationService.syncFCMToken(user.id);
        } catch (_) {}

        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerWithEmail(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure));
      },
      (user) async {
        try {
          await secureNotificationService.syncFCMToken(user.id);
        } catch (_) {}

        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await secureNotificationService.secureLogout();
    } catch (_) {
      await logout();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', false);
    } catch (_) {}
  }
}
