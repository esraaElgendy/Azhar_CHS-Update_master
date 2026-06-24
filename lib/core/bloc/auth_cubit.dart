import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../repositories/auth_repository.dart';

// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final UserModel? user;

  const AuthAuthenticated({required this.token, this.user});

  @override
  List<Object?> get props => [token, user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial());

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final token = await _authRepository.getToken();
        emit(AuthAuthenticated(token: token ?? ''));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password
  Future<void> login({
    required String studentId,
    required String email,
    required String password,
    required String language,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(
        studentId: studentId,
        email: email,
        password: password,
        language: language,
      );

      if (response.token.isNotEmpty) {
        emit(AuthAuthenticated(
          token: response.token,
          user: response.user,
        ));
      } else {
        emit(const AuthError('Login failed. Please try again.'));
      }
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An error occurred: ${e.toString()}'));
    }
  }

  /// Register a new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String year,
    required String language,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        studentId: studentId,
        year: year,
        language: language,
      );

      if (response.token.isNotEmpty) {
        emit(AuthAuthenticated(
          token: response.token,
          user: response.user,
        ));
      } else {
        emit(const AuthError('Registration failed. Please try again.'));
      }
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An error occurred: ${e.toString()}'));
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
