import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/stock_movement_type.dart';

part 'stock_movement_model.g.dart';

@JsonSerializable()
class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.inventoryItemId,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.unitCost,
    required super.totalCost,
    required super.reason,
    super.serviceId,
    super.reference,
    super.batchNumber,
    required super.createdAt,
    required super.createdBy,
    super.notes,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) => _$StockMovementModelFromJson(json);
  Map<String, dynamic> toJson() => _$StockMovementModelToJson(this);

  factory StockMovementModel.fromEntity(StockMovement movement) {
    return StockMovementModel(
      id: movement.id,
      inventoryItemId: movement.inventoryItemId,
      productId: movement.productId,
      type: movement.type,
      quantity: movement.quantity,
      unitCost: movement.unitCost,
      totalCost: movement.totalCost,
      reason: movement.reason,
      serviceId: movement.serviceId,
      reference: movement.reference,
      batchNumber: movement.batchNumber,
      createdAt: movement.createdAt,
      createdBy: movement.createdBy,
      notes: movement.notes,
    );
  }

  StockMovement toEntity() {
    return StockMovement(
      id: id,
      inventoryItemId: inventoryItemId,
      productId: productId,
      type: type,
      quantity: quantity,
      unitCost: unitCost,
      totalCost: totalCost,
      reason: reason,
      serviceId: serviceId,
      reference: reference,
      batchNumber: batchNumber,
      createdAt: createdAt,
      createdBy: createdBy,
      notes: notes,
    );
  }
}