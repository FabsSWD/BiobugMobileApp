import 'package:json_annotation/json_annotation.dart';

part 'product_usage_report_model.g.dart';

@JsonSerializable()
class ProductUsageEntryModel {
  final DateTime date;
  final double quantityUsed;
  final double cost;
  final String? serviceId;
  final String reason;

  const ProductUsageEntryModel({
    required this.date,
    required this.quantityUsed,
    required this.cost,
    this.serviceId,
    required this.reason,
  });

  factory ProductUsageEntryModel.fromJson(Map<String, dynamic> json) => _$ProductUsageEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductUsageEntryModelToJson(this);
}

@JsonSerializable()
class ProductUsageReportModel {
  final String productId;
  final String productName;
  final String activeIngredient;
  final DateTime startDate;
  final DateTime endDate;
  final List<ProductUsageEntryModel> usageEntries;
  final double totalQuantityUsed;
  final double totalCost;
  final double averageDailyUsage;
  final int numberOfServices;
  final String unit;
  final DateTime generatedAt;

  const ProductUsageReportModel({
    required this.productId,
    required this.productName,
    required this.activeIngredient,
    required this.startDate,
    required this.endDate,
    required this.usageEntries,
    required this.totalQuantityUsed,
    required this.totalCost,
    required this.averageDailyUsage,
    required this.numberOfServices,
    required this.unit,
    required this.generatedAt,
  });

  factory ProductUsageReportModel.fromJson(Map<String, dynamic> json) => _$ProductUsageReportModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductUsageReportModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'activeIngredient': activeIngredient,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageEntries': usageEntries.map((entry) => entry.toJson()).toList(),
      'totalQuantityUsed': totalQuantityUsed,
      'totalCost': totalCost,
      'averageDailyUsage': averageDailyUsage,
      'numberOfServices': numberOfServices,
      'unit': unit,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}