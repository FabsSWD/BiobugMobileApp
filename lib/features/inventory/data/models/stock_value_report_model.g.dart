// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_value_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockValueItemModel _$StockValueItemModelFromJson(Map<String, dynamic> json) =>
    StockValueItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      activeIngredient: json['activeIngredient'] as String,
      currentStock: (json['currentStock'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      location: json['location'] as String,
      unit: json['unit'] as String,
      isLowStock: json['isLowStock'] as bool,
      isOverStock: json['isOverStock'] as bool,
    );

Map<String, dynamic> _$StockValueItemModelToJson(
  StockValueItemModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'activeIngredient': instance.activeIngredient,
  'currentStock': instance.currentStock,
  'unitCost': instance.unitCost,
  'totalValue': instance.totalValue,
  'location': instance.location,
  'unit': instance.unit,
  'isLowStock': instance.isLowStock,
  'isOverStock': instance.isOverStock,
};

StockValueReportModel _$StockValueReportModelFromJson(
  Map<String, dynamic> json,
) => StockValueReportModel(
  items: (json['items'] as List<dynamic>)
      .map((e) => StockValueItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalValue: (json['totalValue'] as num).toDouble(),
  totalItems: (json['totalItems'] as num).toInt(),
  lowStockItems: (json['lowStockItems'] as num).toInt(),
  overStockItems: (json['overStockItems'] as num).toInt(),
  outOfStockItems: (json['outOfStockItems'] as num).toInt(),
  valueByLocation: (json['valueByLocation'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$StockValueReportModelToJson(
  StockValueReportModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalValue': instance.totalValue,
  'totalItems': instance.totalItems,
  'lowStockItems': instance.lowStockItems,
  'overStockItems': instance.overStockItems,
  'outOfStockItems': instance.outOfStockItems,
  'valueByLocation': instance.valueByLocation,
  'generatedAt': instance.generatedAt.toIso8601String(),
};
