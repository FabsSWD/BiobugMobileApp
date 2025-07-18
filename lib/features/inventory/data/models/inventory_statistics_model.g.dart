// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryStatisticsModel _$InventoryStatisticsModelFromJson(
  Map<String, dynamic> json,
) => InventoryStatisticsModel(
  totalProducts: (json['totalProducts'] as num).toInt(),
  activeProducts: (json['activeProducts'] as num).toInt(),
  inactiveProducts: (json['inactiveProducts'] as num).toInt(),
  lowStockItems: (json['lowStockItems'] as num).toInt(),
  outOfStockItems: (json['outOfStockItems'] as num).toInt(),
  overStockItems: (json['overStockItems'] as num).toInt(),
  expiringProducts: (json['expiringProducts'] as num).toInt(),
  expiredProducts: (json['expiredProducts'] as num).toInt(),
  totalStockValue: (json['totalStockValue'] as num).toDouble(),
  averageStockValue: (json['averageStockValue'] as num).toDouble(),
  totalSuppliers: (json['totalSuppliers'] as num).toInt(),
  activeSuppliers: (json['activeSuppliers'] as num).toInt(),
  totalAlerts: (json['totalAlerts'] as num).toInt(),
  unreadAlerts: (json['unreadAlerts'] as num).toInt(),
  unresolvedAlerts: (json['unresolvedAlerts'] as num).toInt(),
  alertsByType: Map<String, int>.from(json['alertsByType'] as Map),
  alertsByPriority: Map<String, int>.from(json['alertsByPriority'] as Map),
  stockValueByLocation: (json['stockValueByLocation'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$InventoryStatisticsModelToJson(
  InventoryStatisticsModel instance,
) => <String, dynamic>{
  'totalProducts': instance.totalProducts,
  'activeProducts': instance.activeProducts,
  'inactiveProducts': instance.inactiveProducts,
  'lowStockItems': instance.lowStockItems,
  'outOfStockItems': instance.outOfStockItems,
  'overStockItems': instance.overStockItems,
  'expiringProducts': instance.expiringProducts,
  'expiredProducts': instance.expiredProducts,
  'totalStockValue': instance.totalStockValue,
  'averageStockValue': instance.averageStockValue,
  'totalSuppliers': instance.totalSuppliers,
  'activeSuppliers': instance.activeSuppliers,
  'totalAlerts': instance.totalAlerts,
  'unreadAlerts': instance.unreadAlerts,
  'unresolvedAlerts': instance.unresolvedAlerts,
  'alertsByType': instance.alertsByType,
  'alertsByPriority': instance.alertsByPriority,
  'stockValueByLocation': instance.stockValueByLocation,
  'generatedAt': instance.generatedAt.toIso8601String(),
};
