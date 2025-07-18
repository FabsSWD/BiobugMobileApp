import 'package:json_annotation/json_annotation.dart';

part 'inventory_statistics_model.g.dart';

@JsonSerializable()
class InventoryStatisticsModel {
  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int lowStockItems;
  final int outOfStockItems;
  final int overStockItems;
  final int expiringProducts;
  final int expiredProducts;
  final double totalStockValue;
  final double averageStockValue;
  final int totalSuppliers;
  final int activeSuppliers;
  final int totalAlerts;
  final int unreadAlerts;
  final int unresolvedAlerts;
  final Map<String, int> alertsByType;
  final Map<String, int> alertsByPriority;
  final Map<String, double> stockValueByLocation;
  final DateTime generatedAt;

  const InventoryStatisticsModel({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.overStockItems,
    required this.expiringProducts,
    required this.expiredProducts,
    required this.totalStockValue,
    required this.averageStockValue,
    required this.totalSuppliers,
    required this.activeSuppliers,
    required this.totalAlerts,
    required this.unreadAlerts,
    required this.unresolvedAlerts,
    required this.alertsByType,
    required this.alertsByPriority,
    required this.stockValueByLocation,
    required this.generatedAt,
  });

  factory InventoryStatisticsModel.fromJson(Map<String, dynamic> json) => _$InventoryStatisticsModelFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryStatisticsModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'inactiveProducts': inactiveProducts,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'overStockItems': overStockItems,
      'expiringProducts': expiringProducts,
      'expiredProducts': expiredProducts,
      'totalStockValue': totalStockValue,
      'averageStockValue': averageStockValue,
      'totalSuppliers': totalSuppliers,
      'activeSuppliers': activeSuppliers,
      'totalAlerts': totalAlerts,
      'unreadAlerts': unreadAlerts,
      'unresolvedAlerts': unresolvedAlerts,
      'alertsByType': alertsByType,
      'alertsByPriority': alertsByPriority,
      'stockValueByLocation': stockValueByLocation,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}