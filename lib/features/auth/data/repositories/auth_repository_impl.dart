import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
      _debugPrint('AuthRepository.login - Start');
      _debugPrint('Username: ${params.username}');
      
      // Check network in parallel with other prep work
      final requestModel = LoginRequestModel.fromEntity(params);
      final isConnected = await _networkInfo.isConnected;
      
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet. Verifique su conexión.',
        ));
      }

      // Perform API call and caching in sequence (but optimized)
      final authResultModel = await _remoteDataSource.login(requestModel);
      _debugPrint('Login API call successful');

      // Cache in parallel with other operations if possible
      final cacheOperation = _localDataSource.cacheAuthResult(authResultModel);
      final authResult = authResultModel.toEntity();
      
      // Wait for caching to complete
      await cacheOperation;
      _debugPrint('Auth result cached');

      // REMOVED: await Future.delayed(const Duration(milliseconds: 100));
      // Optimized user data check - no artificial delay
      if (authResult.user == null) {
        _debugPrint('No user data in auth result, checking cache');
        
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser != null) {
          _debugPrint('Found cached user data after login');
          return Right(AuthResult(
            token: authResult.token,
            refreshToken: authResult.refreshToken,
            tokenExpiration: authResult.tokenExpiration,
            user: cachedUser.toEntity(),
          ));
        }
      }

      _debugPrint('Login completed successfully');
      return Right(authResult);
      
    } on ValidationException catch (e) {
      _debugPrint('Validation error in login: ${e.message}');
      return Left(e.toFailure());
    } on AuthenticationException catch (e) {
      _debugPrint('Authentication error in login: ${e.message}');
      return Left(e.toFailure());
    } on NetworkException catch (e) {
      _debugPrint('Network error in login: ${e.message}');
      return Left(e.toFailure());
    } on ServerException catch (e) {
      _debugPrint('Server error in login: ${e.message}');
      return Left(e.toFailure());
    } on CacheException catch (e) {
      _debugPrint('Cache error in login: ${e.message}');
      return const Left(CacheFailure(
        'Login exitoso pero falló el almacenamiento local',
      ));
    } catch (e) {
      _debugPrint('Unexpected error in login: $e');
      return Left(ServerFailure('Error inesperado durante el login: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register(RegisterParams params) async {
    try {
      _debugPrint('AuthRepository.register - Start');
      
      // Parallel network check and request preparation
      final requestModel = RegisterRequestModel.fromEntity(params);
      final isConnected = await _networkInfo.isConnected;
      
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet. Verifique su conexión.',
        ));
      }

      // API call and caching optimization
      final authResultModel = await _remoteDataSource.register(requestModel);
      _debugPrint('Register API call successful');

      // Cache and convert in parallel
      final cacheOperation = _localDataSource.cacheAuthResult(authResultModel);
      final authResult = authResultModel.toEntity();
      
      await cacheOperation;
      _debugPrint('Auth result cached');

      return Right(authResult);
      
    } on ValidationException catch (e) {
      return Left(e.toFailure());
    } on AuthenticationException catch (e) {
      return Left(e.toFailure());
    } on NetworkException catch (e) {
      return Left(e.toFailure());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } on CacheException catch (e) {
      _debugPrint('Warning: Failed to cache auth result: ${e.message}');
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
      _debugPrint('AuthRepository.logout - Start');
      await _localDataSource.clearAuthData();
      _debugPrint('Logout completed successfully');
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
      _debugPrint('AuthRepository.getCurrentUser - Start');
      final userModel = await _localDataSource.getCachedUser();
      final user = userModel?.toEntity();
      _debugPrint('Get current user completed - User: ${user?.fullName ?? 'null'}');
      return Right(user);
    } on CacheException catch (e) {
      _debugPrint('Cache error in getCurrentUser: ${e.message}');
      return Left(e.toFailure());
    } catch (e) {
      _debugPrint('Unexpected error in getCurrentUser: $e');
      return Left(CacheFailure('Error al obtener usuario actual: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      _debugPrint('AuthRepository.isLoggedIn - Start');
      final isLoggedIn = await _localDataSource.isLoggedIn();
      _debugPrint('Is logged in check completed - Result: $isLoggedIn');
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      _debugPrint('Cache error in isLoggedIn: ${e.message}');
      return Left(e.toFailure());
    } catch (e) {
      _debugPrint('Error in isLoggedIn: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, AuthResult>> refreshToken() async {
    try {
      _debugPrint('AuthRepository.refreshToken - Start');
      
      // Parallel operations where possible
      final networkCheckFuture = _networkInfo.isConnected;
      final refreshTokenFuture = _localDataSource.getRefreshToken();
      
      final results = await Future.wait([
        networkCheckFuture,
        refreshTokenFuture,
      ]);
      
      final isConnected = results[0] as bool;
      final refreshToken = results[1] as String?;
      
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet para refrescar el token.',
        ));
      }

      if (refreshToken == null) {
        return const Left(AuthenticationFailure(
          'No se encontró token de actualización',
        ));
      }

      // API call and caching
      final authResultModel = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.cacheAuthResult(authResultModel);

      _debugPrint('Token refresh completed successfully');
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

  // Logging optimizado - solo en debug mode
  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}