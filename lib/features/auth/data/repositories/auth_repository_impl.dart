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

      // Cache the result locally
      await _localDataSource.cacheAuthResult(authResultModel);

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
      // If caching fails, we still return success but log the issue
      // This way the user can still use the app even if caching fails
      print('Warning: Failed to cache auth result: ${e.message}');
      return const Left(CacheFailure(
        'Login exitoso pero falló el almacenamiento local',
      ));
    } catch (e) {
      return Left(ServerFailure('Error inesperado durante el login: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register(RegisterParams params) async {
    try {
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

      // Cache the result locally
      await _localDataSource.cacheAuthResult(authResultModel);

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
      // Clear all local auth data
      await _localDataSource.clearAuthData();
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
      final userModel = await _localDataSource.getCachedUser();
      return Right(userModel?.toEntity());
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(CacheFailure('Error al obtener usuario actual: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await _localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      // If there's any error checking auth status, assume not logged in
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, AuthResult>> refreshToken() async {
    try {
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

      // Return domain entity
      return Right(authResultModel.toEntity());
    } on AuthenticationException catch (e) {
      // If refresh fails, clear local auth data
      await _localDataSource.clearAuthData();
      return Left(e.toFailure());
    } on NetworkException catch (e) {
      return Left(e.toFailure());
    } on ServerException catch (e) {
      // If server error during refresh, clear local auth data
      await _localDataSource.clearAuthData();
      return Left(e.toFailure());
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      // Clear auth data on any unexpected error
      await _localDataSource.clearAuthData();
      return Left(ServerFailure('Error inesperado al refrescar token: $e'));
    }
  }
}