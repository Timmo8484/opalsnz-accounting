import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.errorMessage});

  final AuthStatus status;
  final String? errorMessage;

  AuthState copyWith({AuthStatus? status, String? errorMessage}) => AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage,
      );
}

abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested(this.username, this.password);
  final String username;
  final String password;
}

class AuthLoggedOut extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authService) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  final AuthService _authService;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final loggedIn = await _authService.isLoggedIn();
    emit(state.copyWith(status: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated));
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    final success = await _authService.login(event.username, event.password);
    emit(success
        ? state.copyWith(status: AuthStatus.authenticated)
        : state.copyWith(status: AuthStatus.unauthenticated, errorMessage: 'Invalid username or password'));
  }

  Future<void> _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
