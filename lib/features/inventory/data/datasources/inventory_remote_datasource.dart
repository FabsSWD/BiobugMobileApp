import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_movement_model.dart';
import '../models/inventory_alert_model.dart';
import '../models/supplier_model.dart';

abstract class InventoryRemoteDataSource {
  // Product operations
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);

  // Inventory item operations
  Future<List<InventoryItemModel>> getInventoryItems();
  Future<InventoryItemModel> getInventoryItemById(String id);
  Future<void> createInventoryItem(InventoryItemModel item);
  Future<void> updateInventoryItem(InventoryItemModel item);
  Future<void> deleteInventoryItem(String id);

  // Stock movement operations
  Future<List<StockMovementModel>> getStockMovements();
  Future<void> createStockMovement(StockMovementModel movement);
  Future<List<StockMovementModel>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate);

  // Alert operations
  Future<List<InventoryAlertModel>> getInventoryAlerts();
  Future<void> createAlert(InventoryAlertModel alert);
  Future<void> updateAlert(InventoryAlertModel alert);

  // Supplier operations
  Future<List<SupplierModel>> getSuppliers();
  Future<SupplierModel> getSupplierById(String id);
  Future<void> createSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);

  // Sync operations
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> localData);
  Future<void> uploadInventoryData(Map<String, dynamic> data);
  Future<Map<String, dynamic>> downloadInventoryData();
}

@LazySingleton(as: InventoryRemoteDataSource)
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSourceImpl(this._apiClient);

  // Product operations
  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiClient.get('/inventory/products');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener productos del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener productos: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/inventory/products/$id');
      
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data['product']);
      } else {
        throw ServerException(
          'Error al obtener producto del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener producto: $e');
    }
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    try {
      final response = await _apiClient.post(
        '/inventory/products',
        data: product.toJson(),
      );
      
      if (response.statusCode != 201) {
        throw ServerException(
          'Error al crear producto en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al crear producto: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final response = await _apiClient.put(
        '/inventory/products/${product.id}',
        data: product.toJson(),
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al actualizar producto en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al actualizar producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final response = await _apiClient.delete('/inventory/products/$id');
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al eliminar producto del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al eliminar producto: $e');
    }
  }

  // Inventory item operations
  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    try {
      final response = await _apiClient.get('/inventory/items');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'];
        return data.map((json) => InventoryItemModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener items de inventario del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener items de inventario: $e');
    }
  }

  @override
  Future<InventoryItemModel> getInventoryItemById(String id) async {
    try {
      final response = await _apiClient.get('/inventory/items/$id');
      
      if (response.statusCode == 200) {
        return InventoryItemModel.fromJson(response.data['item']);
      } else {
        throw ServerException(
          'Error al obtener item de inventario del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener item de inventario: $e');
    }
  }

  @override
  Future<void> createInventoryItem(InventoryItemModel item) async {
    try {
      final response = await _apiClient.post(
        '/inventory/items',
        data: item.toJson(),
      );
      
      if (response.statusCode != 201) {
        throw ServerException(
          'Error al crear item de inventario en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al crear item de inventario: $e');
    }
  }

  @override
  Future<void> updateInventoryItem(InventoryItemModel item) async {
    try {
      final response = await _apiClient.put(
        '/inventory/items/${item.id}',
        data: item.toJson(),
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al actualizar item de inventario en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al actualizar item de inventario: $e');
    }
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    try {
      final response = await _apiClient.delete('/inventory/items/$id');
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al eliminar item de inventario del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al eliminar item de inventario: $e');
    }
  }

  // Stock movement operations
  @override
  Future<List<StockMovementModel>> getStockMovements() async {
    try {
      final response = await _apiClient.get('/inventory/movements');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['movements'];
        return data.map((json) => StockMovementModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener movimientos de stock del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener movimientos de stock: $e');
    }
  }

  @override
  Future<void> createStockMovement(StockMovementModel movement) async {
    try {
      final response = await _apiClient.post(
        '/inventory/movements',
        data: movement.toJson(),
      );
      
      if (response.statusCode != 201) {
        throw ServerException(
          'Error al crear movimiento de stock en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al crear movimiento de stock: $e');
    }
  }

  @override
  Future<List<StockMovementModel>> getStockMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _apiClient.get(
        '/inventory/movements',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['movements'];
        return data.map((json) => StockMovementModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener movimientos de stock por rango de fechas del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener movimientos por rango de fechas: $e');
    }
  }

  // Alert operations
  @override
  Future<List<InventoryAlertModel>> getInventoryAlerts() async {
    try {
      final response = await _apiClient.get('/inventory/alerts');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['alerts'];
        return data.map((json) => InventoryAlertModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener alertas de inventario del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener alertas de inventario: $e');
    }
  }

  @override
  Future<void> createAlert(InventoryAlertModel alert) async {
    try {
      final response = await _apiClient.post(
        '/inventory/alerts',
        data: alert.toJson(),
      );
      
      if (response.statusCode != 201) {
        throw ServerException(
          'Error al crear alerta de inventario en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al crear alerta de inventario: $e');
    }
  }

  @override
  Future<void> updateAlert(InventoryAlertModel alert) async {
    try {
      final response = await _apiClient.put(
        '/inventory/alerts/${alert.id}',
        data: alert.toJson(),
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al actualizar alerta de inventario en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al actualizar alerta de inventario: $e');
    }
  }

  // Supplier operations
  @override
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final response = await _apiClient.get('/inventory/suppliers');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['suppliers'];
        return data.map((json) => SupplierModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener proveedores del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener proveedores: $e');
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final response = await _apiClient.get('/inventory/suppliers/$id');
      
      if (response.statusCode == 200) {
        return SupplierModel.fromJson(response.data['supplier']);
      } else {
        throw ServerException(
          'Error al obtener proveedor del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al obtener proveedor: $e');
    }
  }

  @override
  Future<void> createSupplier(SupplierModel supplier) async {
    try {
      final response = await _apiClient.post(
        '/inventory/suppliers',
        data: supplier.toJson(),
      );
      
      if (response.statusCode != 201) {
        throw ServerException(
          'Error al crear proveedor en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al crear proveedor: $e');
    }
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      final response = await _apiClient.put(
        '/inventory/suppliers/${supplier.id}',
        data: supplier.toJson(),
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al actualizar proveedor en el servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al actualizar proveedor: $e');
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      final response = await _apiClient.delete('/inventory/suppliers/$id');
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al eliminar proveedor del servidor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al eliminar proveedor: $e');
    }
  }

  // Sync operations
  @override
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> localData) async {
    try {
      final response = await _apiClient.post(
        '/inventory/sync',
        data: localData,
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          'Error al sincronizar datos de inventario',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al sincronizar datos: $e');
    }
  }

  @override
  Future<void> uploadInventoryData(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/inventory/upload',
        data: data,
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al subir datos de inventario',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al subir datos: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> downloadInventoryData() async {
    try {
      final response = await _apiClient.get('/inventory/download');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          'Error al descargar datos de inventario',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Error de conexión al descargar datos: $e');
    }
  }
}