import 'package:injectable/injectable.dart';
import '../entities/inventory_alert_priority.dart';
import '../entities/inventory_item.dart';
import '../entities/product.dart';
import '../entities/stock_movement.dart';
import '../entities/stock_movement_type.dart';

abstract class InventoryService {
  bool shouldCreateLowStockAlert(InventoryItem item);
  bool shouldCreateExpirationAlert(Product product, int daysThreshold);
  double calculateTotalInventoryValue(List<InventoryItem> items, List<Product> products);
  List<InventoryItem> getItemsNeedingAttention(List<InventoryItem> items);
  String generateBatchNumber();
  bool isStockMovementValid(StockMovement movement, InventoryItem currentItem);
  InventoryAlertPriority getAlertPriorityForStockLevel(InventoryItem item);
  Map<String, double> calculateConsumptionTrends(List<StockMovement> movements);
  List<String> getLocationSuggestions(List<InventoryItem> existingItems);
  bool isProductCodeUnique(String code, List<Product> existingProducts, String? currentProductId);
}

@LazySingleton(as: InventoryService)
class InventoryServiceImpl implements InventoryService {
  @override
  bool shouldCreateLowStockAlert(InventoryItem item) {
    return item.currentStock <= item.minimumStock && item.currentStock > 0;
  }

  @override
  bool shouldCreateExpirationAlert(Product product, int daysThreshold) {
    final now = DateTime.now();
    final daysUntilExpiration = product.expirationDate.difference(now).inDays;
    return daysUntilExpiration <= daysThreshold && daysUntilExpiration >= 0;
  }

  @override
  double calculateTotalInventoryValue(List<InventoryItem> items, List<Product> products) {
    double totalValue = 0;
    
    for (final item in items) {
      final product = products.where((p) => p.id == item.productId).firstOrNull;
      if (product != null) {
        totalValue += item.currentStock * product.unitCost;
      }
    }
    
    return totalValue;
  }

  @override
  List<InventoryItem> getItemsNeedingAttention(List<InventoryItem> items) {
    return items.where((item) => 
      item.isOutOfStock || 
      item.isLowStock || 
      item.isOverStock ||
      item.currentStock < 0 // Stock negativo
    ).toList();
  }

  @override
  String generateBatchNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'BATCH-$dateStr-${timestamp.toString().substring(timestamp.toString().length - 6)}';
  }

  @override
  bool isStockMovementValid(StockMovement movement, InventoryItem currentItem) {
    // Validar que el movimiento no resulte en stock negativo para movimientos de salida
    if (movement.type == StockMovementType.consumption || 
        movement.type == StockMovementType.waste ||
        movement.type == StockMovementType.transfer) {
      return currentItem.currentStock >= movement.quantity;
    }
    
    // Los movimientos de entrada siempre son válidos en términos de cantidad
    return true;
  }

  @override
  InventoryAlertPriority getAlertPriorityForStockLevel(InventoryItem item) {
    if (item.isOutOfStock || item.currentStock < 0) {
      return InventoryAlertPriority.critical;
    } else if (item.currentStock <= (item.minimumStock * 0.5)) {
      return InventoryAlertPriority.high;
    } else if (item.isLowStock) {
      return InventoryAlertPriority.medium;
    } else if (item.isOverStock) {
      return InventoryAlertPriority.low;
    }
    
    return InventoryAlertPriority.low;
  }

  @override
  Map<String, double> calculateConsumptionTrends(List<StockMovement> movements) {
    final consumptionMovements = movements.where(
      (m) => m.type == StockMovementType.consumption
    ).toList();

    // Agrupar por mes
    final monthlyConsumption = <String, double>{};
    
    for (final movement in consumptionMovements) {
      final monthKey = '${movement.createdAt.year}-${movement.createdAt.month.toString().padLeft(2, '0')}';
      monthlyConsumption[monthKey] = (monthlyConsumption[monthKey] ?? 0) + movement.quantity;
    }
    
    return monthlyConsumption;
  }

  @override
  List<String> getLocationSuggestions(List<InventoryItem> existingItems) {
    final locations = existingItems.map((item) => item.location).toSet().toList();
    locations.sort();
    
    // Agregar algunas sugerencias comunes si no existen
    const commonLocations = [
      'Almacén Principal',
      'Bodega A',
      'Bodega B',
      'Área de Cuarentena',
      'Refrigerador',
      'Laboratorio',
      'Vehículo 1',
      'Vehículo 2',
    ];
    
    for (final location in commonLocations) {
      if (!locations.contains(location)) {
        locations.add(location);
      }
    }
    
    return locations;
  }

  @override
  bool isProductCodeUnique(String code, List<Product> existingProducts, String? currentProductId) {
    return !existingProducts.any((product) => 
      product.sanitaryRegistryNumber == code && 
      product.id != currentProductId
    );
  }
}