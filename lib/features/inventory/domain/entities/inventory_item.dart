import 'package:biobug_mobile_app/features/inventory/domain/entities/product.dart';
import 'package:biobug_mobile_app/features/inventory/domain/entities/stock_status.dart';
import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String productId;
  final Product? product; // Puede ser null si solo tenemos el ID
  final double currentStock;
  final double minimumStock;
  final double maximumStock;
  final String location;
  final String batchNumber;
  final DateTime lastUpdated;
  final String lastUpdatedBy;

  const InventoryItem({
    required this.id,
    required this.productId,
    this.product,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.location,
    required this.batchNumber,
    required this.lastUpdated,
    required this.lastUpdatedBy,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        product,
        currentStock,
        minimumStock,
        maximumStock,
        location,
        batchNumber,
        lastUpdated,
        lastUpdatedBy,
      ];

  bool get isLowStock {
    return currentStock <= minimumStock;
  }

  bool get isOutOfStock {
    return currentStock <= 0;
  }

  bool get isOverStock {
    return currentStock >= maximumStock;
  }

  double get stockPercentage {
    if (maximumStock <= 0) return 0;
    return (currentStock / maximumStock).clamp(0.0, 1.0);
  }

  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    if (isOverStock) return StockStatus.overStock;
    return StockStatus.normal;
  }

  InventoryItem copyWith({
    String? id,
    String? productId,
    Product? product,
    double? currentStock,
    double? minimumStock,
    double? maximumStock,
    String? location,
    String? batchNumber,
    DateTime? lastUpdated,
    String? lastUpdatedBy,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      location: location ?? this.location,
      batchNumber: batchNumber ?? this.batchNumber,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, productId: $productId, currentStock: $currentStock, stockStatus: $stockStatus)';
  }
}