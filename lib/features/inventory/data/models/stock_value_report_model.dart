import 'package:json_annotation/json_annotation.dart';

part 'stock_value_report_model.g.dart';

@JsonSerializable()
class StockValueItemModel {
  final String productId;
  final String productName;
  final String activeIngredient;
  final double currentStock;
  final double unitCost;
  final double totalValue;
  final String location;
  final String unit;
  final bool isLowStock;
  final bool isOverStock;

  const StockValueItemModel({
    required this.productId,
    required this.productName,
    required this.activeIngredient,
    required this.currentStock,
    required this.unitCost,
    required this.totalValue,
    required this.location,
    required this.unit,
    required this.isLowStock,
    required this.isOverStock,
  });

  factory StockValueItemModel.fromJson(Map<String, dynamic> json) => _$StockValueItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$StockValueItemModelToJson(this);
}

@JsonSerializable()
class StockValueReportModel {
  final List<StockValueItemModel> items;
  final double totalValue;
  final int totalItems;
  final int lowStockItems;
  final int overStockItems;
  final int outOfStockItems;
  final Map<String, double> valueByLocation;
  final DateTime generatedAt;

  const StockValueReportModel({
    required this.items,
    required this.totalValue,
    required this.totalItems,
    required this.lowStockItems,
    required this.overStockItems,
    required this.outOfStockItems,
    required this.valueByLocation,
    required this.generatedAt,
  });

  factory StockValueReportModel.fromJson(Map<String, dynamic> json) => _$StockValueReportModelFromJson(json);
  Map<String, dynamic> toJson() => _$StockValueReportModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalValue': totalValue,
      'totalItems': totalItems,
      'lowStockItems': lowStockItems,
      'overStockItems': overStockItems,
      'outOfStockItems': outOfStockItems,
      'valueByLocation': valueByLocation,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}