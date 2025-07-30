import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class RefreshInventory extends InventoryEvent {}

class AddInventoryItemEvent extends InventoryEvent {
  final InventoryItem item;

  const AddInventoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateInventoryItem extends InventoryEvent {
  final InventoryItem item;

  const UpdateInventoryItem(this.item);

  @override
  List<Object?> get props => [item];
}

class FilterInventoryByLocation extends InventoryEvent {
  final String location;

  const FilterInventoryByLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class FilterInventoryByStockLevel extends InventoryEvent {
  final String stockLevel; // 'low', 'out', 'over', 'normal'

  const FilterInventoryByStockLevel(this.stockLevel);

  @override
  List<Object?> get props => [stockLevel];
}