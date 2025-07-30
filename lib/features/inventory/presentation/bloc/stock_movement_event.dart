import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/stock_movement_type.dart';

abstract class StockMovementEvent extends Equatable {
  const StockMovementEvent();

  @override
  List<Object?> get props => [];
}

class LoadStockMovements extends StockMovementEvent {}

class LoadStockMovementsByProduct extends StockMovementEvent {
  final String productId;

  const LoadStockMovementsByProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CreateStockMovementEvent extends StockMovementEvent {
  final StockMovement movement;

  const CreateStockMovementEvent(this.movement);

  @override
  List<Object?> get props => [movement];
}

class FilterStockMovementsByType extends StockMovementEvent {
  final StockMovementType type;

  const FilterStockMovementsByType(this.type);

  @override
  List<Object?> get props => [type];
}

class FilterStockMovementsByDateRange extends StockMovementEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterStockMovementsByDateRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}