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
    print('AuthBloc._onCheckAuthStatus - Start');
    emit(AuthLoading());

    final result = await _checkAuthStatus(NoParams());
    
    await result.fold(
      (failure) async {
        print('Auth status check failed: ${failure.message}');
        emit(AuthError(_createFriendlyFailure(failure, 'check_status')));
      },
      (isLoggedIn) async {
        print('Auth status check result: $isLoggedIn');
        if (isLoggedIn) {
          // Si está logueado, intentar cargar datos del usuario
          await _loadUserData(emit);
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
    print('AuthBloc._onLogin - Start');
    emit(AuthLoading());

    final result = await _loginUser(event.params);
    
    await result.fold(
      (failure) async {
        print('Login failed: ${failure.message}');
        emit(AuthError(_createFriendlyFailure(failure, 'login')));
      },
      (authResult) async {
        print('Login successful');
        print('AuthResult has user data: ${authResult.user != null}');
        
        // Independientemente de si hay datos del usuario en authResult,
        // siempre intentar cargar los datos del usuario después del login
        await _loadUserData(emit);
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc._onRegister - Start');
    emit(AuthLoading());

    final result = await _registerUser(event.params);
    
    await result.fold(
      (failure) async {
        print('Register failed: ${failure.message}');
        emit(AuthError(_createFriendlyFailure(failure, 'register')));
      },
      (authResult) async {
        print('Register successful');
        
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          // Intentar cargar datos del usuario después del registro
          await _loadUserData(emit);
          
          // Si aún no hay datos, mostrar éxito de registro
          if (state is! AuthAuthenticated) {
            emit(AuthRegistrationSuccess());
          }
        }
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc._onLogout - Start');
    emit(AuthLoading());

    final result = await _logoutUser(NoParams());
    
    await result.fold(
      (failure) async {
        print('Logout failed: ${failure.message}');
        // Incluso si el logout falla, limpiar el estado local
        emit(AuthUnauthenticated());
      },
      (_) async {
        print('Logout successful');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onRefreshToken(
    AuthRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc._onRefreshToken - Start');
    
    final result = await _refreshAuthToken(NoParams());
    
    await result.fold(
      (failure) async {
        print('Token refresh failed: ${failure.message}');
        emit(AuthUnauthenticated());
      },
      (authResult) async {
        print('Token refresh successful');
        
        if (authResult.user != null) {
          emit(AuthAuthenticated(authResult.user!));
        } else {
          await _loadUserData(emit);
        }
      },
    );
  }

  /// Método auxiliar para cargar datos del usuario
  Future<void> _loadUserData(Emitter<AuthState> emit) async {
    print('AuthBloc._loadUserData - Start');
    
    try {
      final userResult = await _getCurrentUser(NoParams());
      
      await userResult.fold(
        (failure) async {
          print('Failed to load user data: ${failure.message}');
          emit(AuthError(_createFriendlyFailure(failure, 'get_user')));
        },
        (user) async {
          if (user != null) {
            print('User data loaded successfully: ${user.fullName}');
            emit(AuthAuthenticated(user));
          } else {
            print('No user data found');
            emit(AuthError(CacheFailure(
              'No se pudieron cargar los datos del usuario. Inicia sesión nuevamente.',
            )));
          }
        },
      );
    } catch (e) {
      print('Unexpected error loading user data: $e');
      emit(AuthError(CacheFailure(
        'Error inesperado al cargar datos del usuario.',
      )));
    }
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
    if (failure is AuthenticationFailure || failure is ServerFailure) {
      return AuthenticationFailure(
        'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo nuevamente.',
        failure.code,
      );
    }
    
    if (failure is ValidationFailure) {
      return ValidationFailure(
        'Completa todos los campos correctamente.',
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
    
    return AuthenticationFailure(
      'Error al iniciar sesión. Verifica tus datos e inténtalo nuevamente.',
    );
  }

  Failure _createRegisterFailure(Failure failure) {
    if (failure is ValidationFailure) {
      return ValidationFailure(
        'Completa todos los campos correctamente.',
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
      'No se pudieron cargar los datos del usuario. Inicia sesión nuevamente.',
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
}