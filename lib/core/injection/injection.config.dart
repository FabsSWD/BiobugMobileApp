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
import 'package:biobug_mobile_app/features/inventory/domain/repositories/inventory_repository.dart'
    as _i24;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/add_product.dart'
    as _i913;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/add_supplier.dart'
    as _i109;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/calculate_product_cost.dart'
    as _i25;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/check_stock_alerts.dart'
    as _i678;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/consume_stock.dart'
    as _i591;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/create_stock_movement.dart'
    as _i287;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/delete_product.dart'
    as _i199;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/generate_inventory_report.dart'
    as _i829;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_expiring_products.dart'
    as _i644;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_inventory_alerts.dart'
    as _i915;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_inventory_items.dart'
    as _i1056;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_inventory_statistics.dart'
    as _i489;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_low_stock_items.dart'
    as _i359;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_products.dart'
    as _i556;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_stock_movements.dart'
    as _i149;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/get_suppliers.dart'
    as _i391;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/mark_alert_as_read.dart'
    as _i55;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/search_products.dart'
    as _i198;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/sync_inventory_data.dart'
    as _i226;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/update_product.dart'
    as _i627;
import 'package:biobug_mobile_app/features/inventory/domain/usecases/update_stock.dart'
    as _i826;
import 'package:biobug_mobile_app/features/signature_capture/data/datasources/signature_local_datasource.dart'
    as _i925;
import 'package:biobug_mobile_app/features/signature_capture/data/datasources/signature_remote_datasource.dart'
    as _i38;
import 'package:biobug_mobile_app/features/signature_capture/data/repositories/signature_repository_impl.dart'
    as _i242;
import 'package:biobug_mobile_app/features/signature_capture/domain/repositories/signature_repository.dart'
    as _i884;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/capture_signature.dart'
    as _i975;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/delete_signature.dart'
    as _i592;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/get_saved_signatures.dart'
    as _i342;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/save_signature.dart'
    as _i535;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/upload_signature.dart'
    as _i711;
import 'package:biobug_mobile_app/features/signature_capture/domain/usecases/validate_signature.dart'
    as _i855;
import 'package:biobug_mobile_app/features/signature_capture/presentation/bloc/signature_bloc.dart'
    as _i757;
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
    gh.lazySingleton<_i913.AddProduct>(
      () => _i913.AddProduct(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i109.AddSupplier>(
      () => _i109.AddSupplier(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i25.CalculateProductCost>(
      () => _i25.CalculateProductCost(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i678.CheckStockAlerts>(
      () => _i678.CheckStockAlerts(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i591.ConsumeStock>(
      () => _i591.ConsumeStock(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i287.CreateStockMovement>(
      () => _i287.CreateStockMovement(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i199.DeleteProduct>(
      () => _i199.DeleteProduct(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i829.GenerateInventoryReport>(
      () => _i829.GenerateInventoryReport(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i644.GetExpiringProducts>(
      () => _i644.GetExpiringProducts(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i915.GetInventoryAlerts>(
      () => _i915.GetInventoryAlerts(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i1056.GetInventoryItems>(
      () => _i1056.GetInventoryItems(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i489.GetInventoryStatistics>(
      () => _i489.GetInventoryStatistics(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i359.GetLowStockItems>(
      () => _i359.GetLowStockItems(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i556.GetProducts>(
      () => _i556.GetProducts(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i149.GetStockMovements>(
      () => _i149.GetStockMovements(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i391.GetSuppliers>(
      () => _i391.GetSuppliers(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i55.MarkAlertAsRead>(
      () => _i55.MarkAlertAsRead(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i198.SearchProducts>(
      () => _i198.SearchProducts(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i226.SyncInventoryData>(
      () => _i226.SyncInventoryData(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i627.UpdateProduct>(
      () => _i627.UpdateProduct(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i826.UpdateStock>(
      () => _i826.UpdateStock(gh<_i24.InventoryRepository>()),
    );
    gh.lazySingleton<_i580.NetworkInfo>(
      () => _i580.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i281.AuthLocalDataSource>(
      () => _i281.AuthLocalDataSourceImpl(gh<_i71.SecureStorage>()),
    );
    gh.lazySingleton<_i925.SignatureLocalDataSource>(
      () => _i925.SignatureLocalDataSourceImpl(gh<_i777.LocalStorage>()),
    );
    gh.lazySingleton<_i182.ApiClient>(
      () => _i182.ApiClient(gh<_i71.SecureStorage>()),
    );
    gh.lazySingleton<_i38.SignatureRemoteDataSource>(
      () => _i38.SignatureRemoteDataSourceImpl(gh<_i182.ApiClient>()),
    );
    gh.lazySingleton<_i884.SignatureRepository>(
      () => _i242.SignatureRepositoryImpl(
        gh<_i925.SignatureLocalDataSource>(),
        gh<_i38.SignatureRemoteDataSource>(),
        gh<_i580.NetworkInfo>(),
      ),
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
    gh.lazySingleton<_i975.CaptureSignature>(
      () => _i975.CaptureSignature(gh<_i884.SignatureRepository>()),
    );
    gh.lazySingleton<_i592.DeleteSignature>(
      () => _i592.DeleteSignature(gh<_i884.SignatureRepository>()),
    );
    gh.lazySingleton<_i342.GetSavedSignatures>(
      () => _i342.GetSavedSignatures(gh<_i884.SignatureRepository>()),
    );
    gh.lazySingleton<_i535.SaveSignature>(
      () => _i535.SaveSignature(gh<_i884.SignatureRepository>()),
    );
    gh.lazySingleton<_i711.UploadSignature>(
      () => _i711.UploadSignature(gh<_i884.SignatureRepository>()),
    );
    gh.lazySingleton<_i855.ValidateSignature>(
      () => _i855.ValidateSignature(gh<_i884.SignatureRepository>()),
    );
    gh.factory<_i757.SignatureBloc>(
      () => _i757.SignatureBloc(
        gh<_i975.CaptureSignature>(),
        gh<_i535.SaveSignature>(),
        gh<_i855.ValidateSignature>(),
        gh<_i711.UploadSignature>(),
        gh<_i342.GetSavedSignatures>(),
        gh<_i592.DeleteSignature>(),
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
