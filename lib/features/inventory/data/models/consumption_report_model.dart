import 'package:json_annotation/json_annotation.dart';

part 'consumption_report_model.g.dart';

@JsonSerializable()
class ConsumptionReportItemModel {
  final String productId;
  final String productName;
  final String activeIngredient;
  final double totalQuantityConsumed;
  final double totalCost;
  final int numberOfServices;
  final double averageCostPerService;
  final String unit;

  const ConsumptionReportItemModel({
    required this.productId,
    required this.productName,
    required this.activeIngredient,
    required this.totalQuantityConsumed,
    required this.totalCost,
    required this.numberOfServices,
    required this.averageCostPerService,
    required this.unit,
  });

  factory ConsumptionReportItemModel.fromJson(Map<String, dynamic> json) => _$ConsumptionReportItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConsumptionReportItemModelToJson(this);
}

@JsonSerializable()
class ConsumptionReportModel {
  final DateTime startDate;
  final DateTime endDate;
  final List<ConsumptionReportItemModel> items;
  final double totalCost;
  final double totalQuantity;
  final int totalServices;
  final DateTime generatedAt;

  const ConsumptionReportModel({
    required this.startDate,
    required this.endDate,
    required this.items,
    required this.totalCost,
    required this.totalQuantity,
    required this.totalServices,
    required this.generatedAt,
  });

  factory ConsumptionReportModel.fromJson(Map<String, dynamic> json) => _$ConsumptionReportModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConsumptionReportModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalCost': totalCost,
      'totalQuantity': totalQuantity,
      'totalServices': totalServices,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}