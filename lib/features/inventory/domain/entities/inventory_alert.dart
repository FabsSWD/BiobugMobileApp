import 'package:biobug_mobile_app/features/inventory/domain/entities/inventory_alert_priority.dart';
import 'package:biobug_mobile_app/features/inventory/domain/entities/inventory_alert_type.dart';
import 'package:equatable/equatable.dart';

class InventoryAlert extends Equatable {
  final String id;
  final String inventoryItemId;
  final String productId;
  final InventoryAlertType type;
  final String message;
  final InventoryAlertPriority priority;
  final bool isRead;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final Map<String, dynamic>? metadata;

  const InventoryAlert({
    required this.id,
    required this.inventoryItemId,
    required this.productId,
    required this.type,
    required this.message,
    required this.priority,
    required this.isRead,
    required this.isResolved,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        inventoryItemId,
        productId,
        type,
        message,
        priority,
        isRead,
        isResolved,
        createdAt,
        resolvedAt,
        resolvedBy,
        metadata,
      ];

  InventoryAlert copyWith({
    String? id,
    String? inventoryItemId,
    String? productId,
    InventoryAlertType? type,
    String? message,
    InventoryAlertPriority? priority,
    bool? isRead,
    bool? isResolved,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryAlert(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'InventoryAlert(id: $id, type: $type, priority: $priority, isResolved: $isResolved)';
  }
}