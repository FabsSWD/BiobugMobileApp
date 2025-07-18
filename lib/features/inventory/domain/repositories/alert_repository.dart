import 'package:biobug_mobile_app/features/inventory/domain/entities/inventory_alert_priority.dart';
import 'package:biobug_mobile_app/features/inventory/domain/entities/inventory_alert_type.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/inventory_alert.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<InventoryAlert>>> getAllAlerts();
  Future<Either<Failure, InventoryAlert>> getAlertById(String id);
  Future<Either<Failure, Unit>> createAlert(InventoryAlert alert);
  Future<Either<Failure, Unit>> updateAlert(InventoryAlert alert);
  Future<Either<Failure, Unit>> deleteAlert(String id);
  
  // Alert Status Management
  Future<Either<Failure, Unit>> markAsRead(String alertId);
  Future<Either<Failure, Unit>> markAsResolved(String alertId, String resolvedBy);
  Future<Either<Failure, Unit>> markMultipleAsRead(List<String> alertIds);
  Future<Either<Failure, Unit>> markMultipleAsResolved(List<String> alertIds, String resolvedBy);

  // Alert Filtering
  Future<Either<Failure, List<InventoryAlert>>> getUnreadAlerts();
  Future<Either<Failure, List<InventoryAlert>>> getUnresolvedAlerts();
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByType(InventoryAlertType type);
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByPriority(InventoryAlertPriority priority);
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByProduct(String productId);
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByInventoryItem(String inventoryItemId);
  Future<Either<Failure, List<InventoryAlert>>> getAlertsByDateRange(DateTime startDate, DateTime endDate);

  // Alert Generation
  Future<Either<Failure, Unit>> generateStockAlerts();
  Future<Either<Failure, Unit>> generateExpirationAlerts();
  Future<Either<Failure, Unit>> generateAllAlerts();
  
  // Alert Statistics
  Future<Either<Failure, Map<String, int>>> getAlertStatistics();
  Future<Either<Failure, int>> getUnreadAlertCount();
  Future<Either<Failure, int>> getUnresolvedAlertCount();
  
  // Clean up
  Future<Either<Failure, Unit>> deleteOldAlerts(DateTime cutoffDate);
  Future<Either<Failure, Unit>> deleteResolvedAlerts();
}