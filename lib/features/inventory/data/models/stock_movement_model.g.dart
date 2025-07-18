// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMovementModel _$StockMovementModelFromJson(Map<String, dynamic> json) =>
    StockMovementModel(
      id: json['id'] as String,
      inventoryItemId: json['inventoryItemId'] as String,
      productId: json['productId'] as String,
      type: $enumDecode(_$StockMovementTypeEnumMap, json['type']),
      quantity: (json['quantity'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      reason: json['reason'] as String,
      serviceId: json['serviceId'] as String?,
      reference: json['reference'] as String?,
      batchNumber: json['batchNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$StockMovementModelToJson(StockMovementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inventoryItemId': instance.inventoryItemId,
      'productId': instance.productId,
      'type': _$StockMovementTypeEnumMap[instance.type]!,
      'quantity': instance.quantity,
      'unitCost': instance.unitCost,
      'totalCost': instance.totalCost,
      'reason': instance.reason,
      'serviceId': instance.serviceId,
      'reference': instance.reference,
      'batchNumber': instance.batchNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'notes': instance.notes,
    };

const _$StockMovementTypeEnumMap = {
  StockMovementType.purchase: 'purchase',
  StockMovementType.consumption: 'consumption',
  StockMovementType.adjustment: 'adjustment',
  StockMovementType.waste: 'waste',
  StockMovementType.transfer: 'transfer',
  StockMovementType.return_: 'return_',
};
