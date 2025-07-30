import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_movement.dart';

abstract class StockMovementState extends Equatable {
  const StockMovementState();

  @override
  List<Object?> get props => [];
}

class StockMovementInitial extends StockMovementState {}

class StockMovementLoading extends StockMovementState {}

class StockMovementLoaded extends StockMovementState {
  final List<StockMovement> movements;

  const StockMovementLoaded(this.movements);

  @override
  List<Object?> get props => [movements];
}

class StockMovementCreated extends StockMovementState {
  final StockMovement movement;

  const StockMovementCreated(this.movement);

  @override
  List<Object?> get props => [movement];
}

class StockMovementError extends StockMovementState {
  final String message;

  const StockMovementError(this.message);

  @override
  List<Object?> get props => [message];
}