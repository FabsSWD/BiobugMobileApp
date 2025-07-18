// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsumptionReportItemModel _$ConsumptionReportItemModelFromJson(
  Map<String, dynamic> json,
) => ConsumptionReportItemModel(
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  activeIngredient: json['activeIngredient'] as String,
  totalQuantityConsumed: (json['totalQuantityConsumed'] as num).toDouble(),
  totalCost: (json['totalCost'] as num).toDouble(),
  numberOfServices: (json['numberOfServices'] as num).toInt(),
  averageCostPerService: (json['averageCostPerService'] as num).toDouble(),
  unit: json['unit'] as String,
);

Map<String, dynamic> _$ConsumptionReportItemModelToJson(
  ConsumptionReportItemModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'activeIngredient': instance.activeIngredient,
  'totalQuantityConsumed': instance.totalQuantityConsumed,
  'totalCost': instance.totalCost,
  'numberOfServices': instance.numberOfServices,
  'averageCostPerService': instance.averageCostPerService,
  'unit': instance.unit,
};

ConsumptionReportModel _$ConsumptionReportModelFromJson(
  Map<String, dynamic> json,
) => ConsumptionReportModel(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  items: (json['items'] as List<dynamic>)
      .map(
        (e) => ConsumptionReportItemModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  totalCost: (json['totalCost'] as num).toDouble(),
  totalQuantity: (json['totalQuantity'] as num).toDouble(),
  totalServices: (json['totalServices'] as num).toInt(),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$ConsumptionReportModelToJson(
  ConsumptionReportModel instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'items': instance.items,
  'totalCost': instance.totalCost,
  'totalQuantity': instance.totalQuantity,
  'totalServices': instance.totalServices,
  'generatedAt': instance.generatedAt.toIso8601String(),
};
