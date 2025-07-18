import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/stock_movement_type.dart';
import '../models/product_model.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_movement_model.dart';
import '../models/inventory_alert_model.dart';
import '../models/supplier_model.dart';
import '../models/inventory_statistics_model.dart';
import '../models/consumption_report_model.dart';
import '../models/stock_value_report_model.dart';

abstract class InventoryLocalDataSource {
  // Product operations
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(String id);
  Future<void> saveProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsBySupplier(String supplierId);
  Future<List<ProductModel>> getExpiringProducts(int daysThreshold);
  Future<List<ProductModel>> getExpiredProducts();
  Future<List<ProductModel>> getActiveProducts();

  // Inventory item operations
  Future<List<InventoryItemModel>> getInventoryItems();
  Future<InventoryItemModel?> getInventoryItemById(String id);
  Future<InventoryItemModel?> getInventoryItemByProductId(String productId);
  Future<void> saveInventoryItem(InventoryItemModel item);
  Future<void> updateInventoryItem(InventoryItemModel item);
  Future<void> deleteInventoryItem(String id);
  Future<List<InventoryItemModel>> getLowStockItems();
  Future<List<InventoryItemModel>> getOutOfStockItems();
  Future<List<InventoryItemModel>> getOverStockItems();
  Future<List<InventoryItemModel>> getInventoryItemsByLocation(String location);

  // Stock movement operations
  Future<List<StockMovementModel>> getStockMovements();
  Future<StockMovementModel?> getStockMovementById(String id);
  Future<void> saveStockMovement(StockMovementModel movement);
  Future<List<StockMovementModel>> getStockMovementsByProduct(String productId);
  Future<List<StockMovementModel>> getStockMovementsByInventoryItem(String inventoryItemId);
  Future<List<StockMovementModel>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate);
  Future<List<StockMovementModel>> getStockMovementsByType(String type);
  Future<List<StockMovementModel>> getStockMovementsByService(String serviceId);

  // Alert operations
  Future<List<InventoryAlertModel>> getInventoryAlerts();
  Future<List<InventoryAlertModel>> getUnreadAlerts();
  Future<List<InventoryAlertModel>> getUnresolvedAlerts();
  Future<void> saveAlert(InventoryAlertModel alert);
  Future<void> updateAlert(InventoryAlertModel alert);
  Future<void> deleteAlert(String id);
  Future<List<InventoryAlertModel>> getAlertsByPriority(String priority);
  Future<List<InventoryAlertModel>> getAlertsByType(String type);

  // Supplier operations
  Future<List<SupplierModel>> getSuppliers();
  Future<SupplierModel?> getSupplierById(String id);
  Future<void> saveSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<List<SupplierModel>> searchSuppliers(String query);
  Future<List<SupplierModel>> getActiveSuppliers();

  // Reports and analytics
  Future<InventoryStatisticsModel> generateInventoryStatistics();
  Future<ConsumptionReportModel> generateConsumptionReport(DateTime startDate, DateTime endDate);
  Future<StockValueReportModel> generateStockValueReport();

  // Batch operations
  Future<void> saveMultipleProducts(List<ProductModel> products);
  Future<void> saveMultipleInventoryItems(List<InventoryItemModel> items);
  Future<void> saveMultipleStockMovements(List<StockMovementModel> movements);
  Future<void> saveMultipleAlerts(List<InventoryAlertModel> alerts);

  // Data management
  Future<void> clearAllData();
  Future<void> clearExpiredData(DateTime cutoffDate);
  Future<Map<String, dynamic>> exportData();
  Future<void> importData(Map<String, dynamic> data);
}

@LazySingleton(as: InventoryLocalDataSource)
class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final LocalStorage _localStorage;

  static const String _productsKey = 'inventory_products';
  static const String _inventoryItemsKey = 'inventory_items';
  static const String _stockMovementsKey = 'stock_movements';
  static const String _alertsKey = 'inventory_alerts';
  static const String _suppliersKey = 'inventory_suppliers';

  InventoryLocalDataSourceImpl(this._localStorage);

  // Product operations
  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final productsJson = _localStorage.getString(_productsKey);
      if (productsJson == null) return [];

      final List<dynamic> productsList = jsonDecode(productsJson);
      return productsList
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error al obtener productos: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final products = await getProducts();
      return products.where((product) => product.id == id).firstOrNull;
    } catch (e) {
      throw CacheException('Error al obtener producto por ID: $e');
    }
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    try {
      final products = await getProducts();
      
      // Remove existing product with same ID
      products.removeWhere((p) => p.id == product.id);
      
      // Add new product
      products.add(product);
      
      // Save to storage
      final productsJson = jsonEncode(products.map((p) => p.toJson()).toList());
      await _localStorage.setString(_productsKey, productsJson);
    } catch (e) {
      throw CacheException('Error al guardar producto: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await saveProduct(product); // Same logic as save
    } catch (e) {
      throw CacheException('Error al actualizar producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final products = await getProducts();
      products.removeWhere((product) => product.id == id);
      
      final productsJson = jsonEncode(products.map((p) => p.toJson()).toList());
      await _localStorage.setString(_productsKey, productsJson);
    } catch (e) {
      throw CacheException('Error al eliminar producto: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final products = await getProducts();
      final lowercaseQuery = query.toLowerCase();
      
      return products.where((product) =>
          product.name.toLowerCase().contains(lowercaseQuery) ||
          product.activeIngredient.toLowerCase().contains(lowercaseQuery) ||
          product.manufacturer.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      throw CacheException('Error al buscar productos: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsBySupplier(String supplierId) async {
    try {
      final products = await getProducts();
      return products.where((product) => product.supplier == supplierId).toList();
    } catch (e) {
      throw CacheException('Error al obtener productos por proveedor: $e');
    }
  }

  @override
  Future<List<ProductModel>> getExpiringProducts(int daysThreshold) async {
    try {
      final products = await getProducts();
      final now = DateTime.now();
      final thresholdDate = now.add(Duration(days: daysThreshold));
      
      return products.where((product) => 
          product.expirationDate.isBefore(thresholdDate) && 
          product.expirationDate.isAfter(now)
      ).toList();
    } catch (e) {
      throw CacheException('Error al obtener productos próximos a vencer: $e');
    }
  }

  @override
  Future<List<ProductModel>> getExpiredProducts() async {
    try {
      final products = await getProducts();
      final now = DateTime.now();
      
      return products.where((product) => product.expirationDate.isBefore(now)).toList();
    } catch (e) {
      throw CacheException('Error al obtener productos vencidos: $e');
    }
  }

  @override
  Future<List<ProductModel>> getActiveProducts() async {
    try {
      final products = await getProducts();
      return products.where((product) => product.isActive).toList();
    } catch (e) {
      throw CacheException('Error al obtener productos activos: $e');
    }
  }

  // Inventory item operations
  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    try {
      final itemsJson = _localStorage.getString(_inventoryItemsKey);
      if (itemsJson == null) return [];

      final List<dynamic> itemsList = jsonDecode(itemsJson);
      return itemsList
          .map((json) => InventoryItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error al obtener items de inventario: $e');
    }
  }

  @override
  Future<InventoryItemModel?> getInventoryItemById(String id) async {
    try {
      final items = await getInventoryItems();
      return items.where((item) => item.id == id).firstOrNull;
    } catch (e) {
      throw CacheException('Error al obtener item de inventario por ID: $e');
    }
  }

  @override
  Future<InventoryItemModel?> getInventoryItemByProductId(String productId) async {
    try {
      final items = await getInventoryItems();
      return items.where((item) => item.productId == productId).firstOrNull;
    } catch (e) {
      throw CacheException('Error al obtener item de inventario por producto: $e');
    }
  }

  @override
  Future<void> saveInventoryItem(InventoryItemModel item) async {
    try {
      final items = await getInventoryItems();
      
      // Remove existing item with same ID
      items.removeWhere((i) => i.id == item.id);
      
      // Add new item
      items.add(item);
      
      // Save to storage
      final itemsJson = jsonEncode(items.map((i) => i.toJson()).toList());
      await _localStorage.setString(_inventoryItemsKey, itemsJson);
    } catch (e) {
      throw CacheException('Error al guardar item de inventario: $e');
    }
  }

  @override
  Future<void> updateInventoryItem(InventoryItemModel item) async {
    try {
      await saveInventoryItem(item); // Same logic as save
    } catch (e) {
      throw CacheException('Error al actualizar item de inventario: $e');
    }
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    try {
      final items = await getInventoryItems();
      items.removeWhere((item) => item.id == id);
      
      final itemsJson = jsonEncode(items.map((i) => i.toJson()).toList());
      await _localStorage.setString(_inventoryItemsKey, itemsJson);
    } catch (e) {
      throw CacheException('Error al eliminar item de inventario: $e');
    }
  }

  @override
  Future<List<InventoryItemModel>> getLowStockItems() async {
    try {
      final items = await getInventoryItems();
      return items.where((item) => item.isLowStock).toList();
    } catch (e) {
      throw CacheException('Error al obtener items con stock bajo: $e');
    }
  }

  @override
  Future<List<InventoryItemModel>> getOutOfStockItems() async {
    try {
      final items = await getInventoryItems();
      return items.where((item) => item.isOutOfStock).toList();
    } catch (e) {
      throw CacheException('Error al obtener items sin stock: $e');
    }
  }

  @override
  Future<List<InventoryItemModel>> getOverStockItems() async {
    try {
      final items = await getInventoryItems();
      return items.where((item) => item.isOverStock).toList();
    } catch (e) {
      throw CacheException('Error al obtener items con sobre stock: $e');
    }
  }

  @override
  Future<List<InventoryItemModel>> getInventoryItemsByLocation(String location) async {
    try {
      final items = await getInventoryItems();
      return items.where((item) => item.location == location).toList();
    } catch (e) {
      throw CacheException('Error al obtener items por ubicación: $e');
    }
  }

  // Stock movement operations
  @override
  Future<List<StockMovementModel>> getStockMovements() async {
    try {
      final movementsJson = _localStorage.getString(_stockMovementsKey);
      if (movementsJson == null) return [];

      final List<dynamic> movementsList = jsonDecode(movementsJson);
      return movementsList
          .map((json) => StockMovementModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error al obtener movimientos de stock: $e');
    }
  }

  @override
  Future<StockMovementModel?> getStockMovementById(String id) async {
    try {
      final movements = await getStockMovements();
      return movements.where((movement) => movement.id == id).firstOrNull;
    } catch (e) {
      throw CacheException('Error al obtener movimiento de stock por ID: $e');
    }
  }

  @override
  Future<void> saveStockMovement(StockMovementModel movement) async {
    try {
      final movements = await getStockMovements();
      
      // Add new movement
      movements.add(movement);
      
      // Save to storage
      final movementsJson = jsonEncode(movements.map((m) => m.toJson()).toList());
      await _localStorage.setString(_stockMovementsKey, movementsJson);
    } catch (e) {
      throw CacheException('Error al guardar movimiento de stock: $e');
    }
  }

  @override
  Future<List<StockMovementModel>> getStockMovementsByProduct(String productId) async {
    try {
      final movements = await getStockMovements();
      return movements.where((movement) => movement.productId == productId).toList();
    } catch (e) {
      throw CacheException('Error al obtener movimientos por producto: $e');
    }
  }

  @override
  Future<List<StockMovementModel>> getStockMovementsByInventoryItem(String inventoryItemId) async {
    try {
      final movements = await getStockMovements();
      return movements.where((movement) => movement.inventoryItemId == inventoryItemId).toList();
    } catch (e) {
      throw CacheException('Error al obtener movimientos por item de inventario: $e');
    }
  }

  @override
  Future<List<StockMovementModel>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final movements = await getStockMovements();
      return movements.where((movement) =>
          movement.createdAt.isAfter(startDate) && movement.createdAt.isBefore(endDate)
      ).toList();
    } catch (e) {
      throw CacheException('Error al obtener movimientos por rango de fechas: $e');
    }
  }

  @override
  Future<List<StockMovementModel>> getStockMovementsByType(String type) async {
    try {
      final movements = await getStockMovements();
      return movements.where((movement) => movement.type.name == type).toList();
    } catch (e) {
      throw CacheException('Error al obtener movimientos por tipo: $e');
    }
  }

  @override
  Future<List<StockMovementModel>> getStockMovementsByService(String serviceId) async {
    try {
      final movements = await getStockMovements();
      return movements.where((movement) => movement.serviceId == serviceId).toList();
    } catch (e) {
      throw CacheException('Error al obtener movimientos por servicio: $e');
    }
  }

  // Alert operations
  @override
  Future<List<InventoryAlertModel>> getInventoryAlerts() async {
    try {
      final alertsJson = _localStorage.getString(_alertsKey);
      if (alertsJson == null) return [];

      final List<dynamic> alertsList = jsonDecode(alertsJson);
      return alertsList
          .map((json) => InventoryAlertModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error al obtener alertas de inventario: $e');
    }
  }

  @override
  Future<List<InventoryAlertModel>> getUnreadAlerts() async {
    try {
      final alerts = await getInventoryAlerts();
      return alerts.where((alert) => !alert.isRead).toList();
    } catch (e) {
      throw CacheException('Error al obtener alertas no leídas: $e');
    }
  }

  @override
  Future<List<InventoryAlertModel>> getUnresolvedAlerts() async {
    try {
      final alerts = await getInventoryAlerts();
      return alerts.where((alert) => !alert.isResolved).toList();
    } catch (e) {
      throw CacheException('Error al obtener alertas no resueltas: $e');
    }
  }

  @override
  Future<void> saveAlert(InventoryAlertModel alert) async {
    try {
      final alerts = await getInventoryAlerts();
      
      // Remove existing alert with same ID
      alerts.removeWhere((a) => a.id == alert.id);
      
      // Add new alert
      alerts.add(alert);
      
      // Save to storage
      final alertsJson = jsonEncode(alerts.map((a) => a.toJson()).toList());
      await _localStorage.setString(_alertsKey, alertsJson);
    } catch (e) {
      throw CacheException('Error al guardar alerta: $e');
    }
  }

  @override
  Future<void> updateAlert(InventoryAlertModel alert) async {
    try {
      await saveAlert(alert); // Same logic as save
    } catch (e) {
      throw CacheException('Error al actualizar alerta: $e');
    }
  }

  @override
  Future<void> deleteAlert(String id) async {
    try {
      final alerts = await getInventoryAlerts();
      alerts.removeWhere((alert) => alert.id == id);
      
      final alertsJson = jsonEncode(alerts.map((a) => a.toJson()).toList());
      await _localStorage.setString(_alertsKey, alertsJson);
    } catch (e) {
      throw CacheException('Error al eliminar alerta: $e');
    }
  }

  @override
  Future<List<InventoryAlertModel>> getAlertsByPriority(String priority) async {
    try {
      final alerts = await getInventoryAlerts();
      return alerts.where((alert) => alert.priority.name == priority).toList();
    } catch (e) {
      throw CacheException('Error al obtener alertas por prioridad: $e');
    }
  }

  @override
  Future<List<InventoryAlertModel>> getAlertsByType(String type) async {
    try {
      final alerts = await getInventoryAlerts();
      return alerts.where((alert) => alert.type.name == type).toList();
    } catch (e) {
      throw CacheException('Error al obtener alertas por tipo: $e');
    }
  }

  // Supplier operations
  @override
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final suppliersJson = _localStorage.getString(_suppliersKey);
      if (suppliersJson == null) return [];

      final List<dynamic> suppliersList = jsonDecode(suppliersJson);
      return suppliersList
          .map((json) => SupplierModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error al obtener proveedores: $e');
    }
  }

  @override
  Future<SupplierModel?> getSupplierById(String id) async {
    try {
      final suppliers = await getSuppliers();
      return suppliers.where((supplier) => supplier.id == id).firstOrNull;
    } catch (e) {
      throw CacheException('Error al obtener proveedor por ID: $e');
    }
  }

  @override
  Future<void> saveSupplier(SupplierModel supplier) async {
    try {
      final suppliers = await getSuppliers();
      
      // Remove existing supplier with same ID
      suppliers.removeWhere((s) => s.id == supplier.id);
      
      // Add new supplier
      suppliers.add(supplier);
      
      // Save to storage
      final suppliersJson = jsonEncode(suppliers.map((s) => s.toJson()).toList());
      await _localStorage.setString(_suppliersKey, suppliersJson);
    } catch (e) {
      throw CacheException('Error al guardar proveedor: $e');
    }
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      await saveSupplier(supplier); // Same logic as save
    } catch (e) {
      throw CacheException('Error al actualizar proveedor: $e');
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      final suppliers = await getSuppliers();
      suppliers.removeWhere((supplier) => supplier.id == id);
      
      final suppliersJson = jsonEncode(suppliers.map((s) => s.toJson()).toList());
      await _localStorage.setString(_suppliersKey, suppliersJson);
    } catch (e) {
      throw CacheException('Error al eliminar proveedor: $e');
    }
  }

  @override
  Future<List<SupplierModel>> searchSuppliers(String query) async {
    try {
      final suppliers = await getSuppliers();
      final lowercaseQuery = query.toLowerCase();
      
      return suppliers.where((supplier) =>
          supplier.name.toLowerCase().contains(lowercaseQuery) ||
          supplier.contactPerson.toLowerCase().contains(lowercaseQuery) ||
          supplier.email.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      throw CacheException('Error al buscar proveedores: $e');
    }
  }

  @override
  Future<List<SupplierModel>> getActiveSuppliers() async {
    try {
      final suppliers = await getSuppliers();
      return suppliers.where((supplier) => supplier.isActive).toList();
    } catch (e) {
      throw CacheException('Error al obtener proveedores activos: $e');
    }
  }

  // Reports and analytics
  @override
  Future<InventoryStatisticsModel> generateInventoryStatistics() async {
    try {
      final products = await getProducts();
      final items = await getInventoryItems();
      final alerts = await getInventoryAlerts();
      final suppliers = await getSuppliers();

      final activeProducts = products.where((p) => p.isActive).length;
      final lowStockItems = items.where((i) => i.isLowStock).length;
      final outOfStockItems = items.where((i) => i.isOutOfStock).length;
      final overStockItems = items.where((i) => i.isOverStock).length;
      final expiringProducts = products.where((p) => p.isExpiringSoon).length;
      final expiredProducts = products.where((p) => p.isExpired).length;
      final totalStockValue = items.fold<double>(0, (sum, item) => sum + (item.currentStock * (item.product?.unitCost ?? 0)));
      final unreadAlerts = alerts.where((a) => !a.isRead).length;
      final unresolvedAlerts = alerts.where((a) => !a.isResolved).length;
      final activeSuppliers = suppliers.where((s) => s.isActive).length;

      final alertsByType = <String, int>{};
      final alertsByPriority = <String, int>{};
      final stockValueByLocation = <String, double>{};

      for (final alert in alerts) {
        alertsByType[alert.type.name] = (alertsByType[alert.type.name] ?? 0) + 1;
        alertsByPriority[alert.priority.name] = (alertsByPriority[alert.priority.name] ?? 0) + 1;
      }

      for (final item in items) {
        final value = item.currentStock * (item.product?.unitCost ?? 0);
        stockValueByLocation[item.location] = (stockValueByLocation[item.location] ?? 0) + value;
      }

      return InventoryStatisticsModel(
        totalProducts: products.length,
        activeProducts: activeProducts,
        inactiveProducts: products.length - activeProducts,
        lowStockItems: lowStockItems,
        outOfStockItems: outOfStockItems,
        overStockItems: overStockItems,
        expiringProducts: expiringProducts,
        expiredProducts: expiredProducts,
        totalStockValue: totalStockValue,
        averageStockValue: items.isNotEmpty ? totalStockValue / items.length : 0,
        totalSuppliers: suppliers.length,
        activeSuppliers: activeSuppliers,
        totalAlerts: alerts.length,
        unreadAlerts: unreadAlerts,
        unresolvedAlerts: unresolvedAlerts,
        alertsByType: alertsByType,
        alertsByPriority: alertsByPriority,
        stockValueByLocation: stockValueByLocation,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw CacheException('Error al generar estadísticas de inventario: $e');
    }
  }

  @override
  Future<ConsumptionReportModel> generateConsumptionReport(DateTime startDate, DateTime endDate) async {
    try {
      final movements = await getStockMovementsByDateRange(startDate, endDate);
      final consumptionMovements = movements.where((m) => m.type == StockMovementType.consumption).toList();
      final products = await getProducts();

      final itemsMap = <String, ConsumptionReportItemModel>{};
      double totalCost = 0;
      double totalQuantity = 0;
      final Set<String> serviceIds = {};

      for (final movement in consumptionMovements) {
        final product = products.where((p) => p.id == movement.productId).firstOrNull;
        if (product == null) continue;

        final key = movement.productId;
        if (itemsMap.containsKey(key)) {
          final existingItem = itemsMap[key]!;
          itemsMap[key] = ConsumptionReportItemModel(
            productId: existingItem.productId,
            productName: existingItem.productName,
            activeIngredient: existingItem.activeIngredient,
            totalQuantityConsumed: existingItem.totalQuantityConsumed + movement.quantity,
            totalCost: existingItem.totalCost + movement.totalCost,
            numberOfServices: existingItem.numberOfServices + (movement.serviceId != null ? 1 : 0),
            averageCostPerService: (existingItem.totalCost + movement.totalCost) / 
                (existingItem.numberOfServices + (movement.serviceId != null ? 1 : 0)).clamp(1, double.infinity),
            unit: existingItem.unit,
          );
        } else {
          itemsMap[key] = ConsumptionReportItemModel(
            productId: product.id,
            productName: product.name,
            activeIngredient: product.activeIngredient,
            totalQuantityConsumed: movement.quantity,
            totalCost: movement.totalCost,
            numberOfServices: movement.serviceId != null ? 1 : 0,
            averageCostPerService: movement.totalCost,
            unit: product.unit,
          );
        }

        totalCost += movement.totalCost;
        totalQuantity += movement.quantity;
        if (movement.serviceId != null) {
          serviceIds.add(movement.serviceId!);
        }
      }

      return ConsumptionReportModel(
        startDate: startDate,
        endDate: endDate,
        items: itemsMap.values.toList(),
        totalCost: totalCost,
        totalQuantity: totalQuantity,
        totalServices: serviceIds.length,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw CacheException('Error al generar reporte de consumo: $e');
    }
  }

  @override
  Future<StockValueReportModel> generateStockValueReport() async {
    try {
      final items = await getInventoryItems();
      final products = await getProducts();

      final reportItems = <StockValueItemModel>[];
      double totalValue = 0;
      int lowStockItems = 0;
      int overStockItems = 0;
      int outOfStockItems = 0;
      final Map<String, double> valueByLocation = {};

      for (final item in items) {
        final product = products.where((p) => p.id == item.productId).firstOrNull;
        if (product == null) continue;

        final itemValue = item.currentStock * product.unitCost;
        totalValue += itemValue;

        if (item.isLowStock) lowStockItems++;
        if (item.isOverStock) overStockItems++;
        if (item.isOutOfStock) outOfStockItems++;

        valueByLocation[item.location] = (valueByLocation[item.location] ?? 0) + itemValue;

        reportItems.add(StockValueItemModel(
          productId: product.id,
          productName: product.name,
          activeIngredient: product.activeIngredient,
          currentStock: item.currentStock,
          unitCost: product.unitCost,
          totalValue: itemValue,
          location: item.location,
          unit: product.unit,
          isLowStock: item.isLowStock,
          isOverStock: item.isOverStock,
        ));
      }

      return StockValueReportModel(
        items: reportItems,
        totalValue: totalValue,
        totalItems: items.length,
        lowStockItems: lowStockItems,
        overStockItems: overStockItems,
        outOfStockItems: outOfStockItems,
        valueByLocation: valueByLocation,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw CacheException('Error al generar reporte de valor de stock: $e');
    }
  }

  // Batch operations
  @override
  Future<void> saveMultipleProducts(List<ProductModel> products) async {
    try {
      final existingProducts = await getProducts();
      
      for (final product in products) {
        existingProducts.removeWhere((p) => p.id == product.id);
        existingProducts.add(product);
      }
      
      final productsJson = jsonEncode(existingProducts.map((p) => p.toJson()).toList());
      await _localStorage.setString(_productsKey, productsJson);
    } catch (e) {
      throw CacheException('Error al guardar múltiples productos: $e');
    }
  }

  @override
  Future<void> saveMultipleInventoryItems(List<InventoryItemModel> items) async {
    try {
      final existingItems = await getInventoryItems();
      
      for (final item in items) {
        existingItems.removeWhere((i) => i.id == item.id);
        existingItems.add(item);
      }
      
      final itemsJson = jsonEncode(existingItems.map((i) => i.toJson()).toList());
      await _localStorage.setString(_inventoryItemsKey, itemsJson);
    } catch (e) {
      throw CacheException('Error al guardar múltiples items de inventario: $e');
    }
  }

  @override
  Future<void> saveMultipleStockMovements(List<StockMovementModel> movements) async {
    try {
      final existingMovements = await getStockMovements();
      existingMovements.addAll(movements);
      
      final movementsJson = jsonEncode(existingMovements.map((m) => m.toJson()).toList());
      await _localStorage.setString(_stockMovementsKey, movementsJson);
    } catch (e) {
      throw CacheException('Error al guardar múltiples movimientos de stock: $e');
    }
  }

  @override
  Future<void> saveMultipleAlerts(List<InventoryAlertModel> alerts) async {
    try {
      final existingAlerts = await getInventoryAlerts();
      
      for (final alert in alerts) {
        existingAlerts.removeWhere((a) => a.id == alert.id);
        existingAlerts.add(alert);
      }
      
      final alertsJson = jsonEncode(existingAlerts.map((a) => a.toJson()).toList());
      await _localStorage.setString(_alertsKey, alertsJson);
    } catch (e) {
      throw CacheException('Error al guardar múltiples alertas: $e');
    }
  }

  // Data management
  @override
  Future<void> clearAllData() async {
    try {
      await _localStorage.remove(_productsKey);
      await _localStorage.remove(_inventoryItemsKey);
      await _localStorage.remove(_stockMovementsKey);
      await _localStorage.remove(_alertsKey);
      await _localStorage.remove(_suppliersKey);
    } catch (e) {
      throw CacheException('Error al limpiar todos los datos: $e');
    }
  }

  @override
  Future<void> clearExpiredData(DateTime cutoffDate) async {
    try {
      final movements = await getStockMovements();
      final validMovements = movements.where((m) => m.createdAt.isAfter(cutoffDate)).toList();
      
      final movementsJson = jsonEncode(validMovements.map((m) => m.toJson()).toList());
      await _localStorage.setString(_stockMovementsKey, movementsJson);

      final alerts = await getInventoryAlerts();
      final validAlerts = alerts.where((a) => a.createdAt.isAfter(cutoffDate)).toList();
      
      final alertsJson = jsonEncode(validAlerts.map((a) => a.toJson()).toList());
      await _localStorage.setString(_alertsKey, alertsJson);
    } catch (e) {
      throw CacheException('Error al limpiar datos expirados: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportData() async {
    try {
      final products = await getProducts();
      final items = await getInventoryItems();
      final movements = await getStockMovements();
      final alerts = await getInventoryAlerts();
      final suppliers = await getSuppliers();

      return {
        'products': products.map((p) => p.toJson()).toList(),
        'inventoryItems': items.map((i) => i.toJson()).toList(),
        'stockMovements': movements.map((m) => m.toJson()).toList(),
        'alerts': alerts.map((a) => a.toJson()).toList(),
        'suppliers': suppliers.map((s) => s.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw CacheException('Error al exportar datos: $e');
    }
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('products')) {
        final products = (data['products'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await saveMultipleProducts(products);
      }

      if (data.containsKey('inventoryItems')) {
        final items = (data['inventoryItems'] as List)
            .map((json) => InventoryItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await saveMultipleInventoryItems(items);
      }

      if (data.containsKey('stockMovements')) {
        final movements = (data['stockMovements'] as List)
            .map((json) => StockMovementModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await saveMultipleStockMovements(movements);
      }

      if (data.containsKey('alerts')) {
        final alerts = (data['alerts'] as List)
            .map((json) => InventoryAlertModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await saveMultipleAlerts(alerts);
      }

      if (data.containsKey('suppliers')) {
        final suppliers = (data['suppliers'] as List)
            .map((json) => SupplierModel.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final supplier in suppliers) {
          await saveSupplier(supplier);
        }
      }
    } catch (e) {
      throw CacheException('Error al importar datos: $e');
    }
  }
}
