import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../storage/secure_storage.dart';

@LazySingleton()
class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': ApiConstants.contentType,
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Logging interceptor
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers[ApiConstants.authorization] = 
              '${ApiConstants.bearer} $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _secureStorage.clearTokens();
        }
        handler.next(error);
      },
    ));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'El servidor está tardando en responder. Inténtalo nuevamente.',
          'TIMEOUT',
        );
      
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
          'CONNECTION_ERROR',
        );
      
      case DioExceptionType.badResponse:
        return _handleHttpError(error.response!);
      
      case DioExceptionType.cancel:
        return const NetworkException(
          'La operación fue cancelada',
          'REQUEST_CANCELLED',
        );
      
      default:
        return const NetworkException(
          'Error de conexión. Verifica tu conexión a internet.',
          'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  Exception _handleHttpError(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;
    final requestPath = response.requestOptions.path;

    switch (statusCode) {
      case 400:
        // Validation errors
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>?;
          final fieldErrors = <String, List<String>>{};
          
          errors?.forEach((key, value) {
            if (value is List) {
              fieldErrors[key] = value.cast<String>();
            }
          });
          
          return ValidationException(
            _getFriendlyValidationMessage(fieldErrors),
            fieldErrors: fieldErrors,
            code: 'VALIDATION_ERROR',
          );
        }
        
        // Handle specific validation messages
        return ValidationException(
          _getFriendlyBadRequestMessage(data, requestPath),
          code: 'BAD_REQUEST',
        );
      
      case 401:
        return AuthenticationException(
          _getFriendlyAuthMessage(data, requestPath),
          'UNAUTHORIZED',
        );
      
      case 403:
        return UnauthorizedException(
          'No tienes permisos para realizar esta acción. Contacta al administrador.',
          'FORBIDDEN',
        );
      
      case 404:
        return ServerException(
          _getFriendly404Message(requestPath),
          statusCode: statusCode,
          code: 'NOT_FOUND',
        );
      
      case 409:
        return ServerException(
          _getFriendly409Message(data, requestPath),
          statusCode: statusCode,
          code: 'CONFLICT',
        );
      
      case 422:
        return ValidationException(
          _getFriendly422Message(data, requestPath),
          code: 'UNPROCESSABLE_ENTITY',
        );
      
      case 500:
        return ServerException(
          'Error interno del servidor. Inténtalo más tarde o contacta al soporte.',
          statusCode: statusCode,
          errors: data is Map<String, dynamic> ? data['errors'] : null,
          code: 'INTERNAL_SERVER_ERROR',
        );
      
      case 503:
        return ServerException(
          'El servidor está temporalmente fuera de servicio. Inténtalo más tarde.',
          statusCode: statusCode,
          code: 'SERVICE_UNAVAILABLE',
        );
      
      default:
        return ServerException(
          'Error del servidor. Inténtalo nuevamente.',
          statusCode: statusCode,
          code: 'HTTP_ERROR',
        );
    }
  }

  String _getFriendlyValidationMessage(Map<String, List<String>> fieldErrors) {
    if (fieldErrors.isEmpty) return 'Los datos ingresados no son válidos';
    
    final firstError = fieldErrors.entries.first;
    final field = firstError.key;
    final errors = firstError.value;
    
    if (errors.isEmpty) return 'Los datos ingresados no son válidos';
    
    // Mapear campos técnicos a nombres amigables
    final friendlyFieldName = _getFriendlyFieldName(field);
    return '$friendlyFieldName: ${errors.first}';
  }

  String _getFriendlyBadRequestMessage(dynamic data, String requestPath) {
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'];
    }
    
    if (requestPath.contains('/auth/login')) {
      return 'Datos de inicio de sesión inválidos';
    }
    
    if (requestPath.contains('/auth/register')) {
      return 'Datos de registro inválidos';
    }
    
    return 'Los datos enviados no son válidos';
  }

  String _getFriendlyAuthMessage(dynamic data, String requestPath) {
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      final message = data['message'].toString().toLowerCase();
      
      if (message.contains('invalid credentials') || 
          message.contains('credenciales') ||
          message.contains('password') ||
          message.contains('contraseña')) {
        return 'Email o contraseña incorrectos';
      }
      
      if (message.contains('user not found') || 
          message.contains('usuario no encontrado')) {
        return 'No existe una cuenta asociada a este email o identificación';
      }
    }
    
    if (requestPath.contains('/auth/login')) {
      return 'Email o contraseña incorrectos';
    }
    
    return 'Credenciales inválidas';
  }

  String _getFriendly404Message(String requestPath) {
    if (requestPath.contains('/auth/login')) {
      return 'Usuario o contraseña Incorrectos';
    }
    
    if (requestPath.contains('/auth/register')) {
      return 'Error en el registro. Verifica tus datos e inténtalo nuevamente.';
    }
    
    if (requestPath.contains('/auth/')) {
      return 'Usuario no encontrado';
    }
    
    return 'El recurso solicitado no existe';
  }

  String _getFriendly409Message(dynamic data, String requestPath) {
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      final message = data['message'].toString().toLowerCase();
      
      if (message.contains('email') || message.contains('correo')) {
        return 'Ya existe una cuenta con este email';
      }
      
      if (message.contains('identification') || message.contains('cedula')) {
        return 'Ya existe una cuenta con este número de identificación';
      }
    }
    
    if (requestPath.contains('/auth/register')) {
      return 'Ya existe una cuenta con estos datos';
    }
    
    return 'Los datos ya existen en el sistema';
  }

  String _getFriendly422Message(dynamic data, String requestPath) {
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'];
    }
    
    if (requestPath.contains('/auth/register')) {
      return 'Los datos de registro no son válidos';
    }
    
    return 'Los datos no pudieron ser procesados';
  }

  String _getFriendlyFieldName(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'email':
        return 'Email';
      case 'password':
        return 'Contraseña';
      case 'username':
        return 'Usuario';
      case 'fullname':
        return 'Nombre completo';
      case 'identification':
        return 'Identificación';
      case 'idtype':
        return 'Tipo de identificación';
      default:
        return fieldName;
    }
  }
}