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
        emit(AuthError(_createFriendlyFailure(failure, 'check_status')));
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await _getCurrentUser(NoParams());
          await userResult.fold(
            (failure) async {
              emit(AuthError(_createFriendlyFailure(failure, 'get_user')));
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
        emit(AuthError(_createFriendlyFailure(failure, 'login')));
      },
      (authResult) async {
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          // Si no hay datos de usuario, intentar cargarlos
          final userResult = await _getCurrentUser(NoParams());
          await userResult.fold(
            (failure) async {
              emit(AuthError(_createFriendlyFailure(failure, 'get_user')));
            },
            (user) async {
              if (user != null) {
                emit(AuthAuthenticated(user));
              } else {
                emit(AuthError(CacheFailure(
                  'Login exitoso pero no se pudieron cargar los datos del usuario. Reinicia la app.',
                )));
              }
            },
          );
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
        emit(AuthError(_createFriendlyFailure(failure, 'register')));
      },
      (authResult) async {
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
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
        // Even if logout fails, we still want to clear local state
        emit(AuthUnauthenticated());
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
    final result = await _refreshAuthToken(NoParams());
    
    await result.fold(
      (failure) async {
        emit(AuthUnauthenticated());
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

  /// Crea mensajes de error más amigables para el usuario
  Failure _createFriendlyFailure(Failure failure, String context) {
    // Si ya es un mensaje amigable, devolverlo tal como está
    if (_isUserFriendlyMessage(failure.message)) {
      return failure;
    }

    // Crear mensajes específicos según el contexto y tipo de error
    switch (context) {
      case 'login':
        return _createLoginFailure(failure);
      case 'register':
        return _createRegisterFailure(failure);
      case 'check_status':
        return _createCheckStatusFailure(failure);
      case 'get_user':
        return _createGetUserFailure(failure);
      default:
        return _createGenericFailure(failure);
    }
  }

  bool _isUserFriendlyMessage(String message) {
    // Verificar si el mensaje ya es amigable
    final friendlyIndicators = [
      'email',
      'contraseña',
      'usuario',
      'cuenta',
      'datos',
      'verifica',
      'inténta',
      'contacta',
    ];
    
    return friendlyIndicators.any((indicator) => 
      message.toLowerCase().contains(indicator));
  }

  Failure _createLoginFailure(Failure failure) {
    if (failure is AuthenticationFailure) {
      return AuthenticationFailure(
        'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo nuevamente.',
        failure.code,
      );
    }
    
    if (failure is ValidationFailure) {
      return ValidationFailure(
        _getLoginValidationMessage(failure.message),
        fieldErrors: failure.fieldErrors,
        code: failure.code,
      );
    }
    
    if (failure is NetworkFailure) {
      return NetworkFailure(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        failure.code,
      );
    }
    
    if (failure is ServerFailure) {
      // Si el mensaje del servidor ya es amigable, usarlo
      if (_isUserFriendlyMessage(failure.message)) {
        return failure;
      }
      
      if (failure.statusCode == 404) {
        return ServerFailure(
          'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo nuevamente.',
          statusCode: failure.statusCode,
          code: failure.code,
        );
      }
      
      if (failure.statusCode == 401) {
        return ServerFailure(
          'Usuario o contraseña incorrectos.',
          statusCode: failure.statusCode,
          code: failure.code,
        );
      }
      
      return ServerFailure(
        'Error del servidor. Inténtalo más tarde.',
        statusCode: failure.statusCode,
        code: failure.code,
      );
    }
    
    return AuthenticationFailure(
      'Error al iniciar sesión. Verifica tus datos e inténtalo nuevamente.',
    );
  }

  Failure _createRegisterFailure(Failure failure) {
    if (failure is ValidationFailure) {
      return ValidationFailure(
        _getRegisterValidationMessage(failure.message),
        fieldErrors: failure.fieldErrors,
        code: failure.code,
      );
    }
    
    if (failure is ServerFailure) {
      if (failure.statusCode == 409) {
        return ServerFailure(
          'Ya existe una cuenta con este email o número de identificación.',
          statusCode: failure.statusCode,
          code: failure.code,
        );
      }
      
      if (failure.statusCode == 422) {
        return ServerFailure(
          'Los datos de registro no son válidos. Verifica la información e inténtalo nuevamente.',
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
    
    if (failure is NetworkFailure) {
      return NetworkFailure(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        failure.code,
      );
    }
    
    return ValidationFailure(
      'Error al crear la cuenta. Verifica los datos e inténtalo nuevamente.',
    );
  }

  Failure _createCheckStatusFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return NetworkFailure(
        'No se pudo verificar el estado de la sesión. Verifica tu conexión a internet.',
        failure.code,
      );
    }
    
    return CacheFailure(
      'Error al verificar la sesión. Inicia sesión nuevamente.',
    );
  }

  Failure _createGetUserFailure(Failure failure) {
    return CacheFailure(
      'Error al cargar los datos del usuario. Inicia sesión nuevamente.',
    );
  }

  Failure _createGenericFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return NetworkFailure(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        failure.code,
      );
    }
    
    return ServerFailure(
      'Error inesperado. Inténtalo más tarde.',
    );
  }

  String _getLoginValidationMessage(String originalMessage) {
    if (originalMessage.toLowerCase().contains('email')) {
      return 'Ingresa un email válido';
    }
    
    if (originalMessage.toLowerCase().contains('password') ||
        originalMessage.toLowerCase().contains('contraseña')) {
      return 'La contraseña es requerida';
    }
    
    if (originalMessage.toLowerCase().contains('username') ||
        originalMessage.toLowerCase().contains('usuario')) {
      return 'Ingresa tu email o número de identificación';
    }
    
    if (originalMessage.toLowerCase().contains('identification') ||
        originalMessage.toLowerCase().contains('cedula')) {
      return 'Ingresa un número de identificación válido';
    }
    
    return 'Completa todos los campos requeridos';
  }

  String _getRegisterValidationMessage(String originalMessage) {
    if (originalMessage.toLowerCase().contains('email')) {
      return 'Ingresa un email válido';
    }
    
    if (originalMessage.toLowerCase().contains('password') ||
        originalMessage.toLowerCase().contains('contraseña')) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    if (originalMessage.toLowerCase().contains('fullname') ||
        originalMessage.toLowerCase().contains('nombre')) {
      return 'El nombre completo es requerido';
    }
    
    if (originalMessage.toLowerCase().contains('identification') ||
        originalMessage.toLowerCase().contains('cedula')) {
      return 'Ingresa un número de identificación válido';
    }
    
    return 'Completa todos los campos correctamente';
  }
}