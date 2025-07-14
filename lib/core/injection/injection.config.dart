// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:biobug_mobile_app/core/injection/injection.dart' as _i692;
import 'package:biobug_mobile_app/core/network/api_client.dart' as _i182;
import 'package:biobug_mobile_app/core/network/network_info.dart' as _i580;
import 'package:biobug_mobile_app/core/storage/local_storage.dart' as _i777;
import 'package:biobug_mobile_app/core/storage/secure_storage.dart' as _i71;
import 'package:biobug_mobile_app/core/utils/input_converter.dart' as _i101;
import 'package:biobug_mobile_app/features/auth/data/datasources/auth_local_datasource.dart'
    as _i281;
import 'package:biobug_mobile_app/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i434;
import 'package:biobug_mobile_app/features/auth/data/repositories/auth_repository_impl.dart'
    as _i409;
import 'package:biobug_mobile_app/features/auth/domain/repositories/auth_repository.dart'
    as _i891;
import 'package:biobug_mobile_app/features/auth/domain/usecases/check_auth_status.dart'
    as _i812;
import 'package:biobug_mobile_app/features/auth/domain/usecases/get_current_user.dart'
    as _i493;
import 'package:biobug_mobile_app/features/auth/domain/usecases/login_user.dart'
    as _i489;
import 'package:biobug_mobile_app/features/auth/domain/usecases/logout_user.dart'
    as _i265;
import 'package:biobug_mobile_app/features/auth/domain/usecases/refresh_auth_token.dart'
    as _i1027;
import 'package:biobug_mobile_app/features/auth/domain/usecases/register_user.dart'
    as _i521;
import 'package:biobug_mobile_app/features/auth/presentation/bloc/auth_bloc.dart'
    as _i958;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i71.SecureStorage>(() => _i71.SecureStorage());
    gh.lazySingleton<_i101.InputConverter>(() => _i101.InputConverter());
    gh.lazySingleton<_i777.LocalStorage>(
      () => _i777.LocalStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i580.NetworkInfo>(
      () => _i580.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i281.AuthLocalDataSource>(
      () => _i281.AuthLocalDataSourceImpl(gh<_i71.SecureStorage>()),
    );
    gh.lazySingleton<_i182.ApiClient>(
      () => _i182.ApiClient(gh<_i71.SecureStorage>()),
    );
    gh.lazySingleton<_i434.AuthRemoteDataSource>(
      () => _i434.AuthRemoteDataSourceImpl(gh<_i182.ApiClient>()),
    );
    gh.lazySingleton<_i891.AuthRepository>(
      () => _i409.AuthRepositoryImpl(
        gh<_i434.AuthRemoteDataSource>(),
        gh<_i281.AuthLocalDataSource>(),
        gh<_i580.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i812.CheckAuthStatus>(
      () => _i812.CheckAuthStatus(gh<_i891.AuthRepository>()),
    );
    gh.lazySingleton<_i493.GetCurrentUser>(
      () => _i493.GetCurrentUser(gh<_i891.AuthRepository>()),
    );
    gh.lazySingleton<_i489.LoginUser>(
      () => _i489.LoginUser(gh<_i891.AuthRepository>()),
    );
    gh.lazySingleton<_i265.LogoutUser>(
      () => _i265.LogoutUser(gh<_i891.AuthRepository>()),
    );
    gh.lazySingleton<_i1027.RefreshAuthToken>(
      () => _i1027.RefreshAuthToken(gh<_i891.AuthRepository>()),
    );
    gh.lazySingleton<_i521.RegisterUser>(
      () => _i521.RegisterUser(gh<_i891.AuthRepository>()),
    );
    gh.factory<_i958.AuthBloc>(
      () => _i958.AuthBloc(
        gh<_i489.LoginUser>(),
        gh<_i521.RegisterUser>(),
        gh<_i265.LogoutUser>(),
        gh<_i493.GetCurrentUser>(),
        gh<_i812.CheckAuthStatus>(),
        gh<_i1027.RefreshAuthToken>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i692.RegisterModule {}
