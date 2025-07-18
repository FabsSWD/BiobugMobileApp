import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_alert.dart';
import '../../domain/entities/inventory_alert_priority.dart' show InventoryAlertPriority;
import '../../domain/entities/inventory_alert_type.dart';

part 'inventory_alert_model.g.dart';

@JsonSerializable()
class InventoryAlertModel extends InventoryAlert {
  const InventoryAlertModel({
    required super.id,
    required super.inventoryItemId,
    required super.productId,
    required super.type,
    required super.message,
    required super.priority,
    required super.isRead,
    required super.isResolved,
    required super.createdAt,
    super.resolvedAt,
    super.resolvedBy,
    super.metadata,
  });

  factory InventoryAlertModel.fromJson(Map<String, dynamic> json) => _$InventoryAlertModelFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryAlertModelToJson(this);

  factory InventoryAlertModel.fromEntity(InventoryAlert alert) {
    return InventoryAlertModel(
      id: alert.id,
      inventoryItemId: alert.inventoryItemId,
      productId: alert.productId,
      type: alert.type,
      message: alert.message,
      priority: alert.priority,
      isRead: alert.isRead,
      isResolved: alert.isResolved,
      createdAt: alert.createdAt,
      resolvedAt: alert.resolvedAt,
      resolvedBy: alert.resolvedBy,
      metadata: alert.metadata,
    );
  }

  InventoryAlert toEntity() {
    return InventoryAlert(
      id: id,
      inventoryItemId: inventoryItemId,
      productId: productId,
      type: type,
      message: message,
      priority: priority,
      isRead: isRead,
      isResolved: isResolved,
      createdAt: createdAt,
      resolvedAt: resolvedAt,
      resolvedBy: resolvedBy,
      metadata: metadata,
    );
  }
}