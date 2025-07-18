import 'package:biobug_mobile_app/features/inventory/domain/entities/inventory_alert_priority.dart';
import 'package:biobug_mobile_app/features/inventory/domain/entities/inventory_alert_type.dart';
import 'package:biobug_mobile_app/features/inventory/domain/entities/stock_movement_type.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/inventory_item.dart';
import '../entities/product.dart';
import '../entities/stock_movement.dart';
import '../entities/inventory_alert.dart';
import '../entities/supplier.dart';

abstract class InventoryRepository {
  // Product Management
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Unit>> addProduct(Product product);
  Future<Either<Failure, Unit>> updateProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(String id);
  Future<Either<Failure, List<Product>>> searchProducts(String query);
  Future<Either<Failure, List<Product>>> getProductsBySupplier(String supplierId);
  Future<Either<Failure, List<Product>>> getExpiringProducts(int daysThreshold);
  Future<Either<Failure, List<Product>>> getExpiredProducts();

  // Inventory Item Management
  Future<Either<Failure, List<InventoryItem>>> getInventoryItems();
  Future<Either<Failure, InventoryItem>> getInventoryItemById(String id);
  Future<Either<Failure, InventoryItem?>> getInventoryItemByProductId(String productId);
  Future<Either<Failure, Unit>> addInventoryItem(InventoryItem item);
  Future<Either<Failure, Unit>> updateInventoryItem(InventoryItem item);
  Future<Either<Failure, Unit>> deleteInventoryItem(String id);
  Future<Either<Failure, List<InventoryItem>>> getLowStockItems();
  Future<Either<Failure, List<InventoryItem>>> getOutOfStockItems();
  Future<Either<Failure, List<InventoryItem>>> getOverStockItems();
  Future<Either<Failure, List<InventoryItem>>> getInventoryItemsByLocation(String location);

  // Stock Movement Management
  Future<Either<Failure, List<StockMovement>>> getStockMovements();
  Future<Either<Failure, StockMovement>> getStockMovementById(String id);
  Future<Either<Failure, Unit>> createStockMovement(StockMovement movement);
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByProduct(String productId);
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByInventoryItem(String inventoryItemId);
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByType(StockMovementType type);
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByService(String serviceId);

  // Inventory Alert Management
  Future<Either<Failure, List<InventoryAlert>>> getInventoryAlerts();
  Future<Either<Failure, List<InventoryAlert>>> getUnreadAlerts();
  Future<Either<Failure, List<InventoryAlert>>> getUnresolvedAlerts();
  Future<Either<Failure, Unit>> markAlertAsRead(String alertId);
  Future<Either<Failure, Unit>> markAlertAsResolved(String alertId, String resolvedBy);
  Future<Either<Failure, Unit>> createAlert(InventoryAlert alert);
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByPriority(InventoryAlertPriority priority);
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByType(InventoryAlertType type);

  // Supplier Management
  Future<Either<Failure, List<Supplier>>> getSuppliers();
  Future<Either<Failure, Supplier>> getSupplierById(String id);
  Future<Either<Failure, Unit>> addSupplier(Supplier supplier);
  Future<Either<Failure, Unit>> updateSupplier(Supplier supplier);
  Future<Either<Failure, Unit>> deleteSupplier(String id);
  Future<Either<Failure, List<Supplier>>> searchSuppliers(String query);
  Future<Either<Failure, List<Supplier>>> getActiveSuppliers();

  // Analytics and Reports
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStatistics();
  Future<Either<Failure, Map<String, dynamic>>> getStockValueReport();
  Future<Either<Failure, Map<String, dynamic>>> getConsumptionReport(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getProductUsageReport(String productId, DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopConsumedProducts(int limit);
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysisReport(DateTime startDate, DateTime endDate);

  // Batch Operations
  Future<Either<Failure, Unit>> updateMultipleStocks(List<InventoryItem> items);
  Future<Either<Failure, Unit>> createMultipleStockMovements(List<StockMovement> movements);
  Future<Either<Failure, Unit>> checkAndCreateAlerts();

  // Data Management
  Future<Either<Failure, Unit>> syncWithRemote();
  Future<Either<Failure, Unit>> exportInventoryData();
  Future<Either<Failure, Unit>> importInventoryData(String filePath);
  Future<Either<Failure, Unit>> clearExpiredData(DateTime cutoffDate);
}