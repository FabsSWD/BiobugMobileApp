import 'package:biobug_mobile_app/features/inventory/domain/entities/stock_movement_type.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/inventory_item.dart';
import '../entities/stock_movement.dart';

abstract class StockRepository {
  // Inventory Item Operations
  Future<Either<Failure, List<InventoryItem>>> getAllInventoryItems();
  Future<Either<Failure, InventoryItem>> getInventoryItemById(String id);
  Future<Either<Failure, InventoryItem?>> getInventoryItemByProductId(String productId);
  Future<Either<Failure, Unit>> createInventoryItem(InventoryItem item);
  Future<Either<Failure, Unit>> updateInventoryItem(InventoryItem item);
  Future<Either<Failure, Unit>> deleteInventoryItem(String id);

  // Stock Level Operations
  Future<Either<Failure, Unit>> updateStock(String inventoryItemId, double newStock);
  Future<Either<Failure, Unit>> adjustStock(String inventoryItemId, double adjustment, String reason);
  Future<Either<Failure, Unit>> consumeStock(String inventoryItemId, double quantity, String? serviceId);
  Future<Either<Failure, Unit>> addStock(String inventoryItemId, double quantity, double unitCost, String? reference);

  // Stock Movement Operations
  Future<Either<Failure, List<StockMovement>>> getAllStockMovements();
  Future<Either<Failure, StockMovement>> getStockMovementById(String id);
  Future<Either<Failure, Unit>> createStockMovement(StockMovement movement);
  Future<Either<Failure, List<StockMovement>>> getMovementsByProduct(String productId);
  Future<Either<Failure, List<StockMovement>>> getMovementsByInventoryItem(String inventoryItemId);
  Future<Either<Failure, List<StockMovement>>> getMovementsByDateRange(DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<StockMovement>>> getMovementsByType(StockMovementType type);
  Future<Either<Failure, List<StockMovement>>> getMovementsByService(String serviceId);

  // Stock Analysis
  Future<Either<Failure, List<InventoryItem>>> getLowStockItems();
  Future<Either<Failure, List<InventoryItem>>> getOutOfStockItems();
  Future<Either<Failure, List<InventoryItem>>> getOverStockItems();
  Future<Either<Failure, List<InventoryItem>>> getItemsByLocation(String location);
  Future<Either<Failure, double>> getTotalStockValue();
  Future<Either<Failure, Map<String, double>>> getStockValueByLocation();
  Future<Either<Failure, Map<String, double>>> getConsumptionByProduct(DateTime startDate, DateTime endDate);

  // Batch Operations
  Future<Either<Failure, Unit>> batchUpdateStock(List<InventoryItem> items);
  Future<Either<Failure, Unit>> batchCreateMovements(List<StockMovement> movements);
}