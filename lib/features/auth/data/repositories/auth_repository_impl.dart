import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, AuthResult>> login(LoginParams params) async {
    try {
      print('AuthRepository.login - Start');
      print('Username: ${params.username}');
      
      // Check if device is connected
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet. Verifique su conexión.',
        ));
      }

      // Prepare request model
      final requestModel = LoginRequestModel.fromEntity(params);

      // Make API call
      final authResultModel = await _remoteDataSource.login(requestModel);
      print('Login API call successful');

      // Cache the result locally
      await _localDataSource.cacheAuthResult(authResultModel);
      print('Auth result cached');

      // Convert to domain entity
      final authResult = authResultModel.toEntity();
      
      // Si no hay datos de usuario en el resultado, intentar obtenerlos
      if (authResult.user == null) {
        print('No user data in auth result, trying to fetch from cache');
        
        // Esperar un poco para que los datos se guarden
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Intentar obtener datos del usuario desde cache
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser != null) {
          print('Found cached user data after login');
          return Right(AuthResult(
            token: authResult.token,
            refreshToken: authResult.refreshToken,
            tokenExpiration: authResult.tokenExpiration,
            user: cachedUser.toEntity(),
          ));
        }
      }

      print('Login completed successfully');
      return Right(authResult);
      
    } on ValidationException catch (e) {
      print('Validation error in login: ${e.message}');
      return Left(e.toFailure());
    } on AuthenticationException catch (e) {
      print('Authentication error in login: ${e.message}');
      return Left(e.toFailure());
    } on NetworkException catch (e) {
      print('Network error in login: ${e.message}');
      return Left(e.toFailure());
    } on ServerException catch (e) {
      print('Server error in login: ${e.message}');
      return Left(e.toFailure());
    } on CacheException catch (e) {
      print('Cache error in login: ${e.message}');
      // If caching fails, we still return success but log the issue
      return const Left(CacheFailure(
        'Login exitoso pero falló el almacenamiento local',
      ));
    } catch (e) {
      print('Unexpected error in login: $e');
      return Left(ServerFailure('Error inesperado durante el login: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register(RegisterParams params) async {
    try {
      print('AuthRepository.register - Start');
      
      // Check if device is connected
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet. Verifique su conexión.',
        ));
      }

      // Prepare request model
      final requestModel = RegisterRequestModel.fromEntity(params);

      // Make API call
      final authResultModel = await _remoteDataSource.register(requestModel);
      print('Register API call successful');

      // Cache the result locally
      await _localDataSource.cacheAuthResult(authResultModel);
      print('Auth result cached');

      // Return domain entity
      return Right(authResultModel.toEntity());
      
    } on ValidationException catch (e) {
      return Left(e.toFailure());
    } on AuthenticationException catch (e) {
      return Left(e.toFailure());
    } on NetworkException catch (e) {
      return Left(e.toFailure());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } on CacheException catch (e) {
      print('Warning: Failed to cache auth result: ${e.message}');
      return const Left(CacheFailure(
        'Registro exitoso pero falló el almacenamiento local',
      ));
    } catch (e) {
      return Left(ServerFailure('Error inesperado durante el registro: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      print('AuthRepository.logout - Start');
      await _localDataSource.clearAuthData();
      print('Logout completed successfully');
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(CacheFailure('Error inesperado durante el logout: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      print('AuthRepository.getCurrentUser - Start');
      final userModel = await _localDataSource.getCachedUser();
      final user = userModel?.toEntity();
      print('Get current user completed - User: ${user?.fullName ?? 'null'}');
      return Right(user);
    } on CacheException catch (e) {
      print('Cache error in getCurrentUser: ${e.message}');
      return Left(e.toFailure());
    } catch (e) {
      print('Unexpected error in getCurrentUser: $e');
      return Left(CacheFailure('Error al obtener usuario actual: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      print('AuthRepository.isLoggedIn - Start');
      final isLoggedIn = await _localDataSource.isLoggedIn();
      print('Is logged in check completed - Result: $isLoggedIn');
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      print('Cache error in isLoggedIn: ${e.message}');
      return Left(e.toFailure());
    } catch (e) {
      print('Error in isLoggedIn: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, AuthResult>> refreshToken() async {
    try {
      print('AuthRepository.refreshToken - Start');
      
      // Check if device is connected
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet para refrescar el token.',
        ));
      }

      // Get refresh token from local storage
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthenticationFailure(
          'No se encontró token de actualización',
        ));
      }

      // Make API call to refresh token
      final authResultModel = await _remoteDataSource.refreshToken(refreshToken);

      // Cache the new result locally
      await _localDataSource.cacheAuthResult(authResultModel);

      print('Token refresh completed successfully');
      return Right(authResultModel.toEntity());
      
    } on AuthenticationException catch (e) {
      await _localDataSource.clearAuthData();
      return Left(e.toFailure());
    } on NetworkException catch (e) {
      return Left(e.toFailure());
    } on ServerException catch (e) {
      await _localDataSource.clearAuthData();
      return Left(e.toFailure());
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      await _localDataSource.clearAuthData();
      return Left(ServerFailure('Error inesperado al refrescar token: $e'));
    }
  }
}