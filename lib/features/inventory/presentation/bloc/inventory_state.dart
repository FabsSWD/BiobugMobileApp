import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> inventoryItems;
  final double totalValue;
  final int lowStockCount;
  final int alertsCount;

  const InventoryLoaded({
    required this.inventoryItems,
    required this.totalValue,
    required this.lowStockCount,
    required this.alertsCount,
  });

  @override
  List<Object?> get props => [inventoryItems, totalValue, lowStockCount, alertsCount];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class InventoryItemUpdated extends InventoryState {
  final InventoryItem item;

  const InventoryItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}