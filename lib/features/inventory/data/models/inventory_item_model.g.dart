// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItemModel _$InventoryItemModelFromJson(Map<String, dynamic> json) =>
    InventoryItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productModel: json['product'] == null
          ? null
          : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      currentStock: (json['currentStock'] as num).toDouble(),
      minimumStock: (json['minimumStock'] as num).toDouble(),
      maximumStock: (json['maximumStock'] as num).toDouble(),
      location: json['location'] as String,
      batchNumber: json['batchNumber'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastUpdatedBy: json['lastUpdatedBy'] as String,
    );

Map<String, dynamic> _$InventoryItemModelToJson(InventoryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'currentStock': instance.currentStock,
      'minimumStock': instance.minimumStock,
      'maximumStock': instance.maximumStock,
      'location': instance.location,
      'batchNumber': instance.batchNumber,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'lastUpdatedBy': instance.lastUpdatedBy,
      'product': instance.productModel,
    };
