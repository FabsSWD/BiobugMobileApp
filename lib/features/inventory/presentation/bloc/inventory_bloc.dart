import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_inventory_items.dart';
import '../../domain/usecases/get_low_stock_items.dart';
import '../../domain/usecases/get_inventory_alerts.dart';
import '../../domain/usecases/calculate_inventory_value.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

@Injectable()
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItems _getInventoryItems;
  final GetLowStockItems _getLowStockItems;
  final GetInventoryAlerts _getInventoryAlerts;
  final CalculateInventoryValue _calculateInventoryValue;
  final GetProducts _getProducts;
  final InventoryRepository _inventoryRepository;

  InventoryBloc(
    this._getInventoryItems,
    this._getLowStockItems,
    this._getInventoryAlerts,
    this._calculateInventoryValue,
    this._getProducts,
    this._inventoryRepository,
  ) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<RefreshInventory>(_onRefreshInventory);
    on<AddInventoryItemEvent>(_onAddInventoryItem);
    on<UpdateInventoryItem>(_onUpdateInventoryItem);
    on<FilterInventoryByLocation>(_onFilterByLocation);
    on<FilterInventoryByStockLevel>(_onFilterByStockLevel);
  }

  Future<void> _onLoadInventory(LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    final result = await _getInventoryItems(NoParams());
    await result.fold(
      (failure) async => emit(InventoryError(failure.message)),
      (inventoryItems) async {
        // Get additional data for dashboard
        final lowStockResult = await _getLowStockItems(NoParams());
        final alertsResult = await _getInventoryAlerts(NoParams());
        final productsResult = await _getProducts(NoParams());

        final lowStockCount = lowStockResult.fold((l) => 0, (items) => items.length);
        final alertsCount = alertsResult.fold((l) => 0, (alerts) => alerts.length);

        // Calculate total value using the new use case
        double totalValue = 0.0;
        await productsResult.fold(
          (failure) => null, // Fallback to 0 value
          (products) async {
            final valueResult = await _calculateInventoryValue(
              CalculateInventoryValueParams(
                items: inventoryItems,
                products: products,
              ),
            );
            valueResult.fold(
              (failure) => null, // Keep 0 value
              (value) => totalValue = value,
            );
          },
        );

        emit(InventoryLoaded(
          inventoryItems: inventoryItems,
          totalValue: totalValue,
          lowStockCount: lowStockCount,
          alertsCount: alertsCount,
        ));
      },
    );
  }

  Future<void> _onRefreshInventory(RefreshInventory event, Emitter<InventoryState> emit) async {
    add(LoadInventory());
  }

  Future<void> _onAddInventoryItem(AddInventoryItemEvent event, Emitter<InventoryState> emit) async {
    try {
      final result = await _inventoryRepository.addInventoryItem(event.item);
      result.fold(
        (failure) => emit(InventoryError(failure.message)),
        (_) {
          add(LoadInventory()); // Refresh the list
        },
      );
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateInventoryItem(UpdateInventoryItem event, Emitter<InventoryState> emit) async {
    final result = await _inventoryRepository.updateInventoryItem(event.item);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) {
        emit(InventoryItemUpdated(event.item));
        add(LoadInventory()); // Refresh the list
      },
    );
  }

  Future<void> _onFilterByLocation(FilterInventoryByLocation event, Emitter<InventoryState> emit) async {
    // Implementation for filtering by location
    if (state is InventoryLoaded) {
      // This would typically involve calling a specific use case
      add(LoadInventory());
    }
  }

  Future<void> _onFilterByStockLevel(FilterInventoryByStockLevel event, Emitter<InventoryState> emit) async {
    // Implementation for filtering by stock level
    if (state is InventoryLoaded) {
      add(LoadInventory());
    }
  }
}