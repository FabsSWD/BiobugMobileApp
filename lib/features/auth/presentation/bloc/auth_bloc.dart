import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/refresh_auth_token.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@Injectable()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;
  final GetCurrentUser _getCurrentUser;
  final CheckAuthStatus _checkAuthStatus;
  final RefreshAuthToken _refreshAuthToken;

  AuthBloc(
    this._loginUser,
    this._registerUser,
    this._logoutUser,
    this._getCurrentUser,
    this._checkAuthStatus,
    this._refreshAuthToken,
  ) : super(AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckAuthStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthRefreshTokenEvent>(_onRefreshToken);
  }

  Future<void> _onCheckAuthStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _checkAuthStatus(NoParams());
    
    await result.fold(
      (failure) async {
        emit(AuthError(failure));
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          // Get current user if logged in
          final userResult = await _getCurrentUser(NoParams());
          await userResult.fold(
            (failure) async {
              emit(AuthError(failure));
            },
            (user) async {
              if (user != null) {
                emit(AuthAuthenticated(user));
              } else {
                emit(AuthUnauthenticated());
              }
            },
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _loginUser(event.params);
    
    await result.fold(
      (failure) async {
        emit(AuthError(failure));
      },
      (authResult) async {
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          // Si no hay userData, intentar obtener datos del usuario
          if (!emit.isDone) {
            add(AuthCheckStatusEvent());
          }
        }
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerUser(event.params);
    
    await result.fold(
      (failure) async {
        emit(AuthError(failure));
      },
      (authResult) async {
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          // Si el registro fue exitoso pero no hay userData,
          // crear un usuario temporal con los datos del registro
          // o redirigir al login
          emit(AuthRegistrationSuccess());
        }
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _logoutUser(NoParams());
    
    await result.fold(
      (failure) async {
        emit(AuthError(failure));
      },
      (_) async {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onRefreshToken(
    AuthRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Don't emit loading for refresh token to avoid UI flicker
    final result = await _refreshAuthToken(NoParams());
    
    await result.fold(
      (failure) async {
        emit(AuthUnauthenticated()); // Force logout on refresh failure
      },
      (authResult) async {
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
}