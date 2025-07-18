// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_usage_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductUsageEntryModel _$ProductUsageEntryModelFromJson(
  Map<String, dynamic> json,
) => ProductUsageEntryModel(
  date: DateTime.parse(json['date'] as String),
  quantityUsed: (json['quantityUsed'] as num).toDouble(),
  cost: (json['cost'] as num).toDouble(),
  serviceId: json['serviceId'] as String?,
  reason: json['reason'] as String,
);

Map<String, dynamic> _$ProductUsageEntryModelToJson(
  ProductUsageEntryModel instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'quantityUsed': instance.quantityUsed,
  'cost': instance.cost,
  'serviceId': instance.serviceId,
  'reason': instance.reason,
};

ProductUsageReportModel _$ProductUsageReportModelFromJson(
  Map<String, dynamic> json,
) => ProductUsageReportModel(
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  activeIngredient: json['activeIngredient'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  usageEntries: (json['usageEntries'] as List<dynamic>)
      .map((e) => ProductUsageEntryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalQuantityUsed: (json['totalQuantityUsed'] as num).toDouble(),
  totalCost: (json['totalCost'] as num).toDouble(),
  averageDailyUsage: (json['averageDailyUsage'] as num).toDouble(),
  numberOfServices: (json['numberOfServices'] as num).toInt(),
  unit: json['unit'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$ProductUsageReportModelToJson(
  ProductUsageReportModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'activeIngredient': instance.activeIngredient,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'usageEntries': instance.usageEntries,
  'totalQuantityUsed': instance.totalQuantityUsed,
  'totalCost': instance.totalCost,
  'averageDailyUsage': instance.averageDailyUsage,
  'numberOfServices': instance.numberOfServices,
  'unit': instance.unit,
  'generatedAt': instance.generatedAt.toIso8601String(),
};
