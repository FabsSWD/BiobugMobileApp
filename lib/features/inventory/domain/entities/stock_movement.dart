import 'package:biobug_mobile_app/features/inventory/domain/entities/stock_movement_type.dart';
import 'package:equatable/equatable.dart';

import 'inventory_item.dart';

class StockMovement extends Equatable {
  final String id;
  final String inventoryItemId;
  final String productId;
  final StockMovementType type;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final String reason;
  final String? serviceId;
  final String? reference;
  final String? batchNumber;
  final DateTime createdAt;
  final String createdBy;
  final String? notes;

  const StockMovement({
    required this.id,
    required this.inventoryItemId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.reason,
    this.serviceId,
    this.reference,
    this.batchNumber,
    required this.createdAt,
    required this.createdBy,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        inventoryItemId,
        productId,
        type,
        quantity,
        unitCost,
        totalCost,
        reason,
        serviceId,
        reference,
        batchNumber,
        createdAt,
        createdBy,
        notes,
      ];

  bool get isIncoming => type == StockMovementType.purchase || type == StockMovementType.adjustment;
  bool get isOutgoing => type == StockMovementType.consumption || type == StockMovementType.waste;

  StockMovement copyWith({
    String? id,
    String? inventoryItemId,
    String? productId,
    StockMovementType? type,
    double? quantity,
    double? unitCost,
    double? totalCost,
    String? reason,
    String? serviceId,
    String? reference,
    String? batchNumber,
    DateTime? createdAt,
    String? createdBy,
    String? notes,
  }) {
    return StockMovement(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      reason: reason ?? this.reason,
      serviceId: serviceId ?? this.serviceId,
      reference: reference ?? this.reference,
      batchNumber: batchNumber ?? this.batchNumber,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'StockMovement(id: $id, type: $type, quantity: $quantity, productId: $productId)';
  }
}

extension StockMovementExtensions on StockMovement {
  static bool isValidMovement(StockMovement movement, InventoryItem currentItem) {
    // Validar que el movimiento no resulte en stock negativo para movimientos de salida
    if (movement.type == StockMovementType.consumption || 
        movement.type == StockMovementType.waste ||
        movement.type == StockMovementType.transfer) {
      return currentItem.currentStock >= movement.quantity;
    }
    
    // Los movimientos de entrada siempre son válidos en términos de cantidad
    return true;
  }
  
  static String generateBatchNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'BATCH-$dateStr-${timestamp.toString().substring(timestamp.toString().length - 6)}';
  }
  
  static Map<String, double> calculateConsumptionTrends(List<StockMovement> movements) {
    final consumptionMovements = movements.where(
      (m) => m.type == StockMovementType.consumption
    ).toList();

    // Agrupar por mes
    final monthlyConsumption = <String, double>{};
    
    for (final movement in consumptionMovements) {
      final monthKey = '${movement.createdAt.year}-${movement.createdAt.month.toString().padLeft(2, '0')}';
      monthlyConsumption[monthKey] = (monthlyConsumption[monthKey] ?? 0) + movement.quantity;
    }
    
    return monthlyConsumption;
  }
}