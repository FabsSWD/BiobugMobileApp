// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryAlertModel _$InventoryAlertModelFromJson(Map<String, dynamic> json) =>
    InventoryAlertModel(
      id: json['id'] as String,
      inventoryItemId: json['inventoryItemId'] as String,
      productId: json['productId'] as String,
      type: $enumDecode(_$InventoryAlertTypeEnumMap, json['type']),
      message: json['message'] as String,
      priority: $enumDecode(_$InventoryAlertPriorityEnumMap, json['priority']),
      isRead: json['isRead'] as bool,
      isResolved: json['isResolved'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$InventoryAlertModelToJson(
  InventoryAlertModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'inventoryItemId': instance.inventoryItemId,
  'productId': instance.productId,
  'type': _$InventoryAlertTypeEnumMap[instance.type]!,
  'message': instance.message,
  'priority': _$InventoryAlertPriorityEnumMap[instance.priority]!,
  'isRead': instance.isRead,
  'isResolved': instance.isResolved,
  'createdAt': instance.createdAt.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolvedBy': instance.resolvedBy,
  'metadata': instance.metadata,
};

const _$InventoryAlertTypeEnumMap = {
  InventoryAlertType.lowStock: 'lowStock',
  InventoryAlertType.outOfStock: 'outOfStock',
  InventoryAlertType.productExpiring: 'productExpiring',
  InventoryAlertType.productExpired: 'productExpired',
  InventoryAlertType.overStock: 'overStock',
  InventoryAlertType.negativeStock: 'negativeStock',
};

const _$InventoryAlertPriorityEnumMap = {
  InventoryAlertPriority.low: 'low',
  InventoryAlertPriority.medium: 'medium',
  InventoryAlertPriority.high: 'high',
  InventoryAlertPriority.critical: 'critical',
};
