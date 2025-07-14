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
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request
            final token = await _secureStorage.getAccessToken();
            error.requestOptions.headers[ApiConstants.authorization] = 
                '${ApiConstants.bearer} $token';
            
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              // If retry fails, continue with original error
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.saveTokens(
          accessToken: data['token'],
          refreshToken: data['tokenRefresh'],
          expirationTime: data['tokenExpiration'],
        );
        return true;
      }
    } catch (e) {
      // Refresh failed, user needs to login again
      await _secureStorage.clearTokens();
    }
    return false;
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
          'Tiempo de conexión agotado. Verifique su conexión a internet.',
          'TIMEOUT',
        );
      
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Error de conexión. Verifique su conexión a internet.',
          'CONNECTION_ERROR',
        );
      
      case DioExceptionType.badResponse:
        return _handleHttpError(error.response!);
      
      case DioExceptionType.cancel:
        return const NetworkException(
          'Solicitud cancelada',
          'REQUEST_CANCELLED',
        );
      
      default:
        return const NetworkException(
          'Error de red desconocido',
          'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  Exception _handleHttpError(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

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
            data['title'] ?? 'Error de validación',
            fieldErrors: fieldErrors,
            code: 'VALIDATION_ERROR',
          );
        }
        return ServerException(
          data['message'] ?? 'Solicitud inválida',
          statusCode: statusCode,
          code: 'BAD_REQUEST',
        );
      
      case 401:
        return AuthenticationException(
          data['message'] ?? 'Credenciales inválidas',
          'UNAUTHORIZED',
        );
      
      case 403:
        return UnauthorizedException(
          'No tiene permisos para realizar esta acción',
          'FORBIDDEN',
        );
      
      case 404:
        return ServerException(
          'Recurso no encontrado',
          statusCode: statusCode,
          code: 'NOT_FOUND',
        );
      
      case 500:
        return ServerException(
          data['message'] ?? 'Error interno del servidor',
          statusCode: statusCode,
          errors: data['errors'],
          code: 'INTERNAL_SERVER_ERROR',
        );
      
      default:
        return ServerException(
          'Error del servidor ($statusCode)',
          statusCode: statusCode,
          code: 'HTTP_ERROR',
        );
    }
  }
}