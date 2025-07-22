import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/inventory_alert_priority.dart' show InventoryAlertPriority;
import '../../domain/entities/inventory_alert_type.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/inventory_alert.dart';
import '../../domain/entities/stock_movement_type.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../models/product_model.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_movement_model.dart';
import '../models/inventory_alert_model.dart';
import '../models/supplier_model.dart';

@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final InventoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // Product Management
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteProducts = await remoteDataSource.getProducts();
        await localDataSource.saveMultipleProducts(remoteProducts);
        return Right(remoteProducts.map((model) => model.toEntity()).toList());
      } else {
        final localProducts = await localDataSource.getProducts();
        return Right(localProducts.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      try {
        final localProducts = await localDataSource.getProducts();
        return Right(localProducts.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteProduct = await remoteDataSource.getProductById(id);
        await localDataSource.saveProduct(remoteProduct);
        return Right(remoteProduct.toEntity());
      } else {
        final localProduct = await localDataSource.getProductById(id);
        if (localProduct != null) {
          return Right(localProduct.toEntity());
        } else {
          return Left(CacheFailure('Producto no encontrado localmente'));
        }
      }
    } on ServerException catch (e) {
      try {
        final localProduct = await localDataSource.getProductById(id);
        if (localProduct != null) {
          return Right(localProduct.toEntity());
        } else {
          return Left(ServerFailure(e.message));
        }
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> addProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      
      // Guardar localmente primero
      await localDataSource.saveProduct(productModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.createProduct(productModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      
      // Actualizar localmente primero
      await localDataSource.updateProduct(productModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateProduct(productModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String id) async {
    try {
      // Eliminar localmente primero
      await localDataSource.deleteProduct(id);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteProduct(id);
        } on ServerException {
          // Si falla en el servidor, mantener cambio localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final localProducts = await localDataSource.searchProducts(query);
      return Right(localProducts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsBySupplier(String supplierId) async {
    try {
      final localProducts = await localDataSource.getProductsBySupplier(supplierId);
      return Right(localProducts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getExpiringProducts(int daysThreshold) async {
    try {
      final localProducts = await localDataSource.getExpiringProducts(daysThreshold);
      return Right(localProducts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getExpiredProducts() async {
    try {
      final localProducts = await localDataSource.getExpiredProducts();
      return Right(localProducts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Inventory Item Management
  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryItems() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteItems = await remoteDataSource.getInventoryItems();
        await localDataSource.saveMultipleInventoryItems(remoteItems);
        return Right(remoteItems.map((model) => model.toEntity()).toList());
      } else {
        final localItems = await localDataSource.getInventoryItems();
        return Right(localItems.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      try {
        final localItems = await localDataSource.getInventoryItems();
        return Right(localItems.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> getInventoryItemById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteItem = await remoteDataSource.getInventoryItemById(id);
        await localDataSource.saveInventoryItem(remoteItem);
        return Right(remoteItem.toEntity());
      } else {
        final localItem = await localDataSource.getInventoryItemById(id);
        if (localItem != null) {
          return Right(localItem.toEntity());
        } else {
          return Left(CacheFailure('Item de inventario no encontrado localmente'));
        }
      }
    } on ServerException catch (e) {
      try {
        final localItem = await localDataSource.getInventoryItemById(id);
        if (localItem != null) {
          return Right(localItem.toEntity());
        } else {
          return Left(ServerFailure(e.message));
        }
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, InventoryItem?>> getInventoryItemByProductId(String productId) async {
    try {
      final localItem = await localDataSource.getInventoryItemByProductId(productId);
      return Right(localItem?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> addInventoryItem(InventoryItem item) async {
    try {
      final itemModel = InventoryItemModel.fromEntity(item);
      
      // Guardar localmente primero
      await localDataSource.saveInventoryItem(itemModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.createInventoryItem(itemModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateInventoryItem(InventoryItem item) async {
    try {
      final itemModel = InventoryItemModel.fromEntity(item);
      
      // Actualizar localmente primero
      await localDataSource.updateInventoryItem(itemModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateInventoryItem(itemModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInventoryItem(String id) async {
    try {
      // Eliminar localmente primero
      await localDataSource.deleteInventoryItem(id);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteInventoryItem(id);
        } on ServerException {
          // Si falla en el servidor, mantener cambio localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getLowStockItems() async {
    try {
      final localItems = await localDataSource.getLowStockItems();
      return Right(localItems.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getOutOfStockItems() async {
    try {
      final localItems = await localDataSource.getOutOfStockItems();
      return Right(localItems.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getOverStockItems() async {
    try {
      final localItems = await localDataSource.getOverStockItems();
      return Right(localItems.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryItemsByLocation(String location) async {
    try {
      final localItems = await localDataSource.getInventoryItemsByLocation(location);
      return Right(localItems.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Stock Movement Management
  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovements() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteMovements = await remoteDataSource.getStockMovements();
        await localDataSource.saveMultipleStockMovements(remoteMovements);
        return Right(remoteMovements.map((model) => model.toEntity()).toList());
      } else {
        final localMovements = await localDataSource.getStockMovements();
        return Right(localMovements.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      try {
        final localMovements = await localDataSource.getStockMovements();
        return Right(localMovements.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, StockMovement>> getStockMovementById(String id) async {
    try {
      final localMovement = await localDataSource.getStockMovementById(id);
      if (localMovement != null) {
        return Right(localMovement.toEntity());
      } else {
        return Left(CacheFailure('Movimiento de stock no encontrado'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> createStockMovement(StockMovement movement) async {
    try {
      final movementModel = StockMovementModel.fromEntity(movement);
      
      // Guardar localmente primero
      await localDataSource.saveStockMovement(movementModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.createStockMovement(movementModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByProduct(String productId) async {
    try {
      final localMovements = await localDataSource.getStockMovementsByProduct(productId);
      return Right(localMovements.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByInventoryItem(String inventoryItemId) async {
    try {
      final localMovements = await localDataSource.getStockMovementsByInventoryItem(inventoryItemId);
      return Right(localMovements.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final localMovements = await localDataSource.getStockMovementsByDateRange(startDate, endDate);
      return Right(localMovements.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByType(StockMovementType type) async {
    try {
      final localMovements = await localDataSource.getStockMovementsByType(type.name);
      return Right(localMovements.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByService(String serviceId) async {
    try {
      final localMovements = await localDataSource.getStockMovementsByService(serviceId);
      return Right(localMovements.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Inventory Alert Management
  @override
  Future<Either<Failure, List<InventoryAlert>>> getInventoryAlerts() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteAlerts = await remoteDataSource.getInventoryAlerts();
        await localDataSource.saveMultipleAlerts(remoteAlerts);
        return Right(remoteAlerts.map((model) => model.toEntity()).toList());
      } else {
        final localAlerts = await localDataSource.getInventoryAlerts();
        return Right(localAlerts.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      try {
        final localAlerts = await localDataSource.getInventoryAlerts();
        return Right(localAlerts.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryAlert>>> getUnreadAlerts() async {
    try {
      final localAlerts = await localDataSource.getUnreadAlerts();
      return Right(localAlerts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryAlert>>> getUnresolvedAlerts() async {
    try {
      final localAlerts = await localDataSource.getUnresolvedAlerts();
      return Right(localAlerts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAlertAsRead(String alertId) async {
    try {
      final alert = await localDataSource.getInventoryAlerts();
      final alertToUpdate = alert.where((a) => a.id == alertId).firstOrNull;
      
      if (alertToUpdate == null) {
        return Left(CacheFailure('Alerta no encontrada'));
      }

      final updatedAlert = InventoryAlertModel.fromEntity(
        alertToUpdate.toEntity().copyWith(isRead: true)
      );
      
      await localDataSource.updateAlert(updatedAlert);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateAlert(updatedAlert);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAlertAsResolved(String alertId, String resolvedBy) async {
    try {
      final alerts = await localDataSource.getInventoryAlerts();
      final alertToUpdate = alerts.where((a) => a.id == alertId).firstOrNull;
      
      if (alertToUpdate == null) {
        return Left(CacheFailure('Alerta no encontrada'));
      }

      final updatedAlert = InventoryAlertModel.fromEntity(
        alertToUpdate.toEntity().copyWith(
          isResolved: true,
          resolvedAt: DateTime.now(),
          resolvedBy: resolvedBy,
        )
      );
      
      await localDataSource.updateAlert(updatedAlert);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateAlert(updatedAlert);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> createAlert(InventoryAlert alert) async {
    try {
      final alertModel = InventoryAlertModel.fromEntity(alert);
      
      // Guardar localmente primero
      await localDataSource.saveAlert(alertModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.createAlert(alertModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByPriority(InventoryAlertPriority priority) async {
    try {
      final localAlerts = await localDataSource.getAlertsByPriority(priority.name);
      return Right(localAlerts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByType(InventoryAlertType type) async {
    try {
      final localAlerts = await localDataSource.getAlertsByType(type.name);
      return Right(localAlerts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Supplier Management
  @override
  Future<Either<Failure, List<Supplier>>> getSuppliers() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteSuppliers = await remoteDataSource.getSuppliers();
        for (final supplier in remoteSuppliers) {
          await localDataSource.saveSupplier(supplier);
        }
        return Right(remoteSuppliers.map((model) => model.toEntity()).toList());
      } else {
        final localSuppliers = await localDataSource.getSuppliers();
        return Right(localSuppliers.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      try {
        final localSuppliers = await localDataSource.getSuppliers();
        return Right(localSuppliers.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Supplier>> getSupplierById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteSupplier = await remoteDataSource.getSupplierById(id);
        await localDataSource.saveSupplier(remoteSupplier);
        return Right(remoteSupplier.toEntity());
      } else {
        final localSupplier = await localDataSource.getSupplierById(id);
        if (localSupplier != null) {
          return Right(localSupplier.toEntity());
        } else {
          return Left(CacheFailure('Proveedor no encontrado localmente'));
        }
      }
    } on ServerException catch (e) {
      try {
        final localSupplier = await localDataSource.getSupplierById(id);
        if (localSupplier != null) {
          return Right(localSupplier.toEntity());
        } else {
          return Left(ServerFailure(e.message));
        }
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> addSupplier(Supplier supplier) async {
    try {
      final supplierModel = SupplierModel.fromEntity(supplier);
      
      // Guardar localmente primero
      await localDataSource.saveSupplier(supplierModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.createSupplier(supplierModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSupplier(Supplier supplier) async {
    try {
      final supplierModel = SupplierModel.fromEntity(supplier);
      
      // Actualizar localmente primero
      await localDataSource.updateSupplier(supplierModel);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateSupplier(supplierModel);
        } on ServerException {
          // Si falla en el servidor, mantener localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSupplier(String id) async {
    try {
      // Eliminar localmente primero
      await localDataSource.deleteSupplier(id);
      
      // Intentar sincronizar con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteSupplier(id);
        } on ServerException {
          // Si falla en el servidor, mantener cambio localmente para sincronizar después
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> searchSuppliers(String query) async {
    try {
      final localSuppliers = await localDataSource.searchSuppliers(query);
      return Right(localSuppliers.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> getActiveSuppliers() async {
    try {
      final localSuppliers = await localDataSource.getActiveSuppliers();
      return Right(localSuppliers.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Analytics and Reports
  @override
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStatistics() async {
    try {
      final statistics = await localDataSource.generateInventoryStatistics();
      return Right(statistics.toMap());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStockValueReport() async {
    try {
      final report = await localDataSource.generateStockValueReport();
      return Right(report.toMap());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getConsumptionReport(DateTime startDate, DateTime endDate) async {
    try {
      final report = await localDataSource.generateConsumptionReport(startDate, endDate);
      return Right(report.toMap());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductUsageReport(String productId, DateTime startDate, DateTime endDate) async {
    try {
      // Implementar lógica para generar reporte de uso de producto específico
      final movements = await localDataSource.getStockMovementsByProduct(productId);
      final product = await localDataSource.getProductById(productId);
      
      if (product == null) {
        return Left(CacheFailure('Producto no encontrado'));
      }

      final filteredMovements = movements.where((m) =>
        m.createdAt.isAfter(startDate) && 
        m.createdAt.isBefore(endDate) && 
        m.type.name == 'consumption'
      ).toList();

      final totalQuantityUsed = filteredMovements.fold<double>(0, (sum, m) => sum + m.quantity);
      final totalCost = filteredMovements.fold<double>(0, (sum, m) => sum + m.totalCost);
      final numberOfServices = filteredMovements.where((m) => m.serviceId != null).length;
      final daysDifference = endDate.difference(startDate).inDays;
      final averageDailyUsage = daysDifference > 0 ? totalQuantityUsed / daysDifference : 0;

      final reportData = {
        'productId': productId,
        'productName': product.name,
        'activeIngredient': product.activeIngredient,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalQuantityUsed': totalQuantityUsed,
        'totalCost': totalCost,
        'numberOfServices': numberOfServices,
        'averageDailyUsage': averageDailyUsage,
        'unit': product.unit,
        'generatedAt': DateTime.now().toIso8601String(),
      };

      return Right(reportData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopConsumedProducts(int limit) async {
    try {
      final movements = await localDataSource.getStockMovements();
      final consumptionMovements = movements.where((m) => m.type.name == 'consumption').toList();
      
      final productConsumption = <String, double>{};
      for (final movement in consumptionMovements) {
        productConsumption[movement.productId] = (productConsumption[movement.productId] ?? 0) + movement.quantity;
      }

      final sortedProducts = productConsumption.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final limitedProducts = sortedProducts.take(limit).toList();
      final result = <Map<String, dynamic>>[];

      for (final entry in limitedProducts) {
        final product = await localDataSource.getProductById(entry.key);
        if (product != null) {
          result.add({
            'productId': entry.key,
            'productName': product.name,
            'totalQuantityConsumed': entry.value,
            'unit': product.unit,
          });
        }
      }

      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysisReport(DateTime startDate, DateTime endDate) async {
    try {
      final movements = await localDataSource.getStockMovementsByDateRange(startDate, endDate);
      
      double totalPurchaseCost = 0;
      double totalConsumptionCost = 0;
      double totalWasteCost = 0;
      
      for (final movement in movements) {
        switch (movement.type.name) {
          case 'purchase':
            totalPurchaseCost += movement.totalCost;
            break;
          case 'consumption':
            totalConsumptionCost += movement.totalCost;
            break;
          case 'waste':
            totalWasteCost += movement.totalCost;
            break;
        }
      }

      final reportData = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalPurchaseCost': totalPurchaseCost,
        'totalConsumptionCost': totalConsumptionCost,
        'totalWasteCost': totalWasteCost,
        'netCost': totalPurchaseCost - totalConsumptionCost - totalWasteCost,
        'wastePercentage': totalPurchaseCost > 0 ? (totalWasteCost / totalPurchaseCost) * 100 : 0,
        'generatedAt': DateTime.now().toIso8601String(),
      };

      return Right(reportData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // Batch Operations
  @override
  Future<Either<Failure, Unit>> updateMultipleStocks(List<InventoryItem> items) async {
    try {
      final itemModels = items.map((item) => InventoryItemModel.fromEntity(item)).toList();
      await localDataSource.saveMultipleInventoryItems(itemModels);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> createMultipleStockMovements(List<StockMovement> movements) async {
    try {
      final movementModels = movements.map((movement) => StockMovementModel.fromEntity(movement)).toList();
      await localDataSource.saveMultipleStockMovements(movementModels);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> checkAndCreateAlerts() async {
    try {
      final items = await localDataSource.getInventoryItems();
      final products = await localDataSource.getProducts();
      final alerts = <InventoryAlertModel>[];

      // Verificar stock bajo y sin stock
      for (final item in items) {
        if (item.isOutOfStock) {
          alerts.add(_createStockAlert(item, InventoryAlertType.outOfStock, InventoryAlertPriority.critical));
        } else if (item.isLowStock) {
          alerts.add(_createStockAlert(item, InventoryAlertType.lowStock, InventoryAlertPriority.high));
        } else if (item.isOverStock) {
          alerts.add(_createStockAlert(item, InventoryAlertType.overStock, InventoryAlertPriority.medium));
        }
      }

      // Verificar productos próximos a vencer y vencidos
      for (final product in products) {
        if (product.isExpired) {
          alerts.add(_createProductAlert(product, InventoryAlertType.productExpired, InventoryAlertPriority.critical));
        } else if (product.isExpiringSoon) {
          alerts.add(_createProductAlert(product, InventoryAlertType.productExpiring, InventoryAlertPriority.high));
        }
      }

      await localDataSource.saveMultipleAlerts(alerts);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  InventoryAlertModel _createStockAlert(InventoryItemModel item, InventoryAlertType type, InventoryAlertPriority priority) {
    return InventoryAlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + item.id,
      inventoryItemId: item.id,
      productId: item.productId,
      type: type,
      message: _getAlertMessage(type, item.productModel?.name ?? 'Producto desconocido'),
      priority: priority,
      isRead: false,
      isResolved: false,
      createdAt: DateTime.now(),
    );
  }

  InventoryAlertModel _createProductAlert(ProductModel product, InventoryAlertType type, InventoryAlertPriority priority) {
    return InventoryAlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + product.id,
      inventoryItemId: '', // No hay item específico para alertas de producto
      productId: product.id,
      type: type,
      message: _getAlertMessage(type, product.name),
      priority: priority,
      isRead: false,
      isResolved: false,
      createdAt: DateTime.now(),
    );
  }

  String _getAlertMessage(InventoryAlertType type, String productName) {
    switch (type) {
      case InventoryAlertType.lowStock:
        return 'Stock bajo para el producto: $productName';
      case InventoryAlertType.outOfStock:
        return 'Sin stock para el producto: $productName';
      case InventoryAlertType.overStock:
        return 'Sobre stock para el producto: $productName';
      case InventoryAlertType.productExpiring:
        return 'El producto $productName está próximo a vencer';
      case InventoryAlertType.productExpired:
        return 'El producto $productName ha vencido';
      case InventoryAlertType.negativeStock:
        return 'Stock negativo detectado para el producto: $productName';
    }
  }

  // Data Management
  @override
  Future<Either<Failure, Unit>> syncWithRemote() async {
    try {
      if (await networkInfo.isConnected) {
        final localData = await localDataSource.exportData();
        final syncResult = await remoteDataSource.syncData(localData);
        await localDataSource.importData(syncResult);
        return const Right(unit);
      } else {
        return Left(NetworkFailure('No hay conexión a internet'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> exportInventoryData() async {
    try {
      // ignore: unused_local_variable
      final data = await localDataSource.exportData();
      // Aquí se podría implementar la lógica para exportar a archivo
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> importInventoryData(String filePath) async {
    try {
      // Aquí se podría implementar la lógica para leer desde archivo
      // Por ahora retornamos success
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearExpiredData(DateTime cutoffDate) async {
    try {
      await localDataSource.clearExpiredData(cutoffDate);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}