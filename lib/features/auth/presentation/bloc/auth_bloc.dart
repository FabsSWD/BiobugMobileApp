// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
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

  bool? _cachedAuthStatus;
  DateTime? _lastAuthCheck;
  static const Duration _authCacheTimeout = Duration(minutes: 1);
  static const Map<String, String> _contextMessages = {
    'login': 'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo nuevamente.',
    'register': 'Error al crear la cuenta. Verifica los datos e inténtalo nuevamente.',
    'check_status': 'Error al verificar la sesión. Inicia sesión nuevamente.',
    'get_user': 'No se pudieron cargar los datos del usuario. Inicia sesión nuevamente.',
  };
  static final RegExp _friendlyPattern = RegExp(
    r'\b(email|contraseña|usuario|cuenta|datos|verifica|inténta|contacta)\b',
    caseSensitive: false,
  );

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
    if (_isCacheValid() && _cachedAuthStatus != null) {
      _debugPrint('Using cached auth status: $_cachedAuthStatus');
      if (_cachedAuthStatus == true) {
        if (state is! AuthAuthenticated) {
          await _loadUserDataOptimized(emit);
        }
        return;
      } else {
        emit(AuthUnauthenticated());
        return;
      }
    }

    _debugPrint('AuthBloc._onCheckAuthStatus - Start');
    
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }

    try {
      final result = await _checkAuthStatus(NoParams())
          .timeout(const Duration(seconds: 5));
      
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw StateError('Impossible'));
        _debugPrint('Auth status check failed: ${failure.message}');
        _updateAuthCache(false);
        emit(AuthError(_createFriendlyFailure(failure, 'check_status')));
      } else {
        final isLoggedIn = result.fold((l) => throw StateError('Impossible'), (r) => r);
        _debugPrint('Auth status check result: $isLoggedIn');
        _updateAuthCache(isLoggedIn);
        
        if (isLoggedIn) {
          await _loadUserDataOptimized(emit);
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } on TimeoutException {
      _debugPrint('Auth check timeout');
      _updateAuthCache(false);
      emit(const AuthError(NetworkFailure('Timeout verificando autenticación')));
    } catch (e) {
      _debugPrint('Unexpected error in auth check: $e');
      _updateAuthCache(false);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    _debugPrint('AuthBloc._onLogin - Start');
    emit(AuthLoading());

    try {
      final result = await _loginUser(event.params)
          .timeout(const Duration(seconds: 10));
      
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw StateError('Impossible'));
        _debugPrint('Login failed: ${failure.message}');
        _invalidateAuthCache();
        emit(AuthError(_createFriendlyFailure(failure, 'login')));
      } else {
        final authResult = result.fold((l) => throw StateError('Impossible'), (r) => r);
        _debugPrint('Login successful');
        _updateAuthCache(true);
        
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          await _loadUserDataOptimized(emit);
        }
      }
    } on TimeoutException {
      _debugPrint('Login timeout');
      _invalidateAuthCache();
      emit(const AuthError(NetworkFailure('Timeout en inicio de sesión')));
    } catch (e) {
      _debugPrint('Unexpected error in login: $e');
      _invalidateAuthCache();
      emit(const AuthError(ServerFailure('Error inesperado al iniciar sesión')));
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    _debugPrint('AuthBloc._onRegister - Start');
    emit(AuthLoading());

    try {
      final result = await _registerUser(event.params)
          .timeout(const Duration(seconds: 15));
      
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw StateError('Impossible'));
        _debugPrint('Register failed: ${failure.message}');
        emit(AuthError(_createFriendlyFailure(failure, 'register')));
      } else {
        final authResult = result.fold((l) => throw StateError('Impossible'), (r) => r);
        _debugPrint('Register successful');
        _updateAuthCache(true);
        
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          await _loadUserDataOptimized(emit);
          
          if (state is! AuthAuthenticated) {
            emit(AuthRegistrationSuccess());
          }
        }
      }
    } on TimeoutException {
      _debugPrint('Register timeout');
      emit(const AuthError(NetworkFailure('Timeout en registro')));
    } catch (e) {
      _debugPrint('Unexpected error in register: $e');
      emit(const AuthError(ServerFailure('Error inesperado al registrar')));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    _debugPrint('AuthBloc._onLogout - Start');
    emit(AuthLoading());

    _invalidateAuthCache();

    try {
      final result = await _logoutUser(NoParams())
          .timeout(const Duration(seconds: 5));
      
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw StateError('Impossible'));
        _debugPrint('Logout failed: ${failure.message}');
        emit(AuthUnauthenticated());
      } else {
        _debugPrint('Logout successful');
        emit(AuthUnauthenticated());
      }
    } on TimeoutException {
      _debugPrint('Logout timeout');
      emit(AuthUnauthenticated());
    } catch (e) {
      _debugPrint('Unexpected error in logout: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshToken(
    AuthRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    _debugPrint('AuthBloc._onRefreshToken - Start');
    
    try {
      final result = await _refreshAuthToken(NoParams())
          .timeout(const Duration(seconds: 10));
      
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw StateError('Impossible'));
        _debugPrint('Token refresh failed: ${failure.message}');
        _invalidateAuthCache();
        emit(AuthUnauthenticated());
      } else {
        final authResult = result.fold((l) => throw StateError('Impossible'), (r) => r);
        _debugPrint('Token refresh successful');
        _updateAuthCache(true);
        
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          await _loadUserDataOptimized(emit);
        }
      }
    } on TimeoutException {
      _debugPrint('Token refresh timeout');
      _invalidateAuthCache();
      emit(AuthUnauthenticated());
    } catch (e) {
      _debugPrint('Unexpected error in token refresh: $e');
      _invalidateAuthCache();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _loadUserDataOptimized(Emitter<AuthState> emit) async {
    _debugPrint('AuthBloc._loadUserDataOptimized - Start');
    
    if (emit.isDone) {
      _debugPrint('Emitter is done, skipping user data load');
      return;
    }
    
    try {
      final userResult = await _getCurrentUser(NoParams())
          .timeout(const Duration(seconds: 3));
      
      if (emit.isDone) {
        _debugPrint('Emitter completed during user load, skipping emit');
        return;
      }
      
      if (userResult.isLeft()) {
        final failure = userResult.fold((l) => l, (r) => throw StateError('Impossible'));
        _debugPrint('Failed to load user data: ${failure.message}');
        emit(AuthError(_createFriendlyFailure(failure, 'get_user')));
      } else {
        final user = userResult.fold((l) => throw StateError('Impossible'), (r) => r);
        if (user != null) {
          _debugPrint('User data loaded: ${user.fullName}');
          emit(AuthAuthenticated(user));
        } else {
          _debugPrint('No user data found');
          emit(const AuthError(CacheFailure(
            'No se pudieron cargar los datos del usuario. Inicia sesión nuevamente.',
          )));
        }
      }
    } on TimeoutException {
      _debugPrint('User data load timeout');
      if (!emit.isDone) {
        emit(const AuthError(NetworkFailure('Timeout cargando datos del usuario')));
      }
    } catch (e) {
      _debugPrint('Unexpected error loading user data: $e');
      if (!emit.isDone) {
        emit(const AuthError(CacheFailure(
          'Error inesperado al cargar datos del usuario.',
        )));
      }
    }
  }

  bool _isCacheValid() {
    if (_cachedAuthStatus == null || _lastAuthCheck == null) {
      return false;
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastAuthCheck!);
    return difference < _authCacheTimeout;
  }

  void _updateAuthCache(bool isLoggedIn) {
    _cachedAuthStatus = isLoggedIn;
    _lastAuthCheck = DateTime.now();
  }

  void _invalidateAuthCache() {
    _cachedAuthStatus = null;
    _lastAuthCheck = null;
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  Failure _createFriendlyFailure(Failure failure, String context) {
    if (_isUserFriendlyMessage(failure.message)) {
      return failure;
    }

    final contextMessage = _contextMessages[context];
    if (contextMessage != null) {
      return switch (failure.runtimeType) {
        NetworkFailure => NetworkFailure(
          'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
          failure.code,
        ),
        AuthenticationFailure => AuthenticationFailure(contextMessage, failure.code),
        ValidationFailure => ValidationFailure(
          'Completa todos los campos correctamente.',
          fieldErrors: (failure as ValidationFailure).fieldErrors,
          code: failure.code,
        ),
        _ => AuthenticationFailure(contextMessage),
      };
    }

    return _createGenericFailure(failure);
  }

  bool _isUserFriendlyMessage(String message) {
    return _friendlyPattern.hasMatch(message);
  }

  Failure _createLoginFailure(Failure failure) {
    return switch (failure.runtimeType) {
      AuthenticationFailure || ServerFailure => AuthenticationFailure(
        'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo nuevamente.',
        failure.code,
      ),
      ValidationFailure => ValidationFailure(
        'Completa todos los campos correctamente.',
        fieldErrors: (failure as ValidationFailure).fieldErrors,
        code: failure.code,
      ),
      NetworkFailure => NetworkFailure(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        failure.code,
      ),
      _ => const AuthenticationFailure(
        'Error al iniciar sesión. Verifica tus datos e inténtalo nuevamente.',
      ),
    };
  }

  Failure _createRegisterFailure(Failure failure) {
    return switch (failure.runtimeType) {
      ValidationFailure => ValidationFailure(
        'Completa todos los campos correctamente.',
        fieldErrors: (failure as ValidationFailure).fieldErrors,
        code: failure.code,
      ),
      ServerFailure => _handleServerFailure(failure as ServerFailure),
      NetworkFailure => NetworkFailure(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        failure.code,
      ),
      _ => const ValidationFailure(
        'Error al crear la cuenta. Verifica los datos e inténtalo nuevamente.',
      ),
    };
  }

  Failure _handleServerFailure(ServerFailure failure) {
    if (failure.statusCode == 409) {
      return ServerFailure(
        'Ya existe una cuenta con este email o número de identificación.',
        statusCode: failure.statusCode,
        code: failure.code,
      );
    }
    
    return ServerFailure(
      'Error al crear la cuenta. Inténtalo más tarde.',
      statusCode: failure.statusCode,
      code: failure.code,
    );
  }

  Failure _createCheckStatusFailure(Failure failure) {
    return switch (failure.runtimeType) {
      NetworkFailure => NetworkFailure(
        'No se pudo verificar el estado de la sesión. Verifica tu conexión a internet.',
        failure.code,
      ),
      _ => const CacheFailure(
        'Error al verificar la sesión. Inicia sesión nuevamente.',
      ),
    };
  }

  Failure _createGetUserFailure(Failure failure) {
    return const CacheFailure(
      'No se pudieron cargar los datos del usuario. Inicia sesión nuevamente.',
    );
  }

  Failure _createGenericFailure(Failure failure) {
    return switch (failure.runtimeType) {
      NetworkFailure => NetworkFailure(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        failure.code,
      ),
      _ => const ServerFailure(
        'Error inesperado. Inténtalo más tarde.',
      ),
    };
  }
}