import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_stock_movements.dart';
import '../../domain/usecases/create_stock_movement.dart' as create_stock_movement_usecase;
import '../../domain/repositories/inventory_repository.dart';
import 'stock_movement_event.dart';
import 'stock_movement_state.dart';

@Injectable()
class StockMovementBloc extends Bloc<StockMovementEvent, StockMovementState> {
  final GetStockMovements _getStockMovements;
  final create_stock_movement_usecase.CreateStockMovement _createStockMovement;
  final InventoryRepository _inventoryRepository;

  StockMovementBloc(
    this._getStockMovements,
    this._createStockMovement,
    this._inventoryRepository,
  ) : super(StockMovementInitial()) {
    on<LoadStockMovements>(_onLoadStockMovements);
    on<LoadStockMovementsByProduct>(_onLoadStockMovementsByProduct);
    on<CreateStockMovementEvent>(_onCreateStockMovement);
    on<FilterStockMovementsByType>(_onFilterByType);
    on<FilterStockMovementsByDateRange>(_onFilterByDateRange);
  }

  Future<void> _onLoadStockMovements(LoadStockMovements event, Emitter<StockMovementState> emit) async {
    emit(StockMovementLoading());

    final result = await _getStockMovements(NoParams());
    result.fold(
      (failure) => emit(StockMovementError(failure.message)),
      (movements) => emit(StockMovementLoaded(movements)),
    );
  }

  Future<void> _onLoadStockMovementsByProduct(LoadStockMovementsByProduct event, Emitter<StockMovementState> emit) async {
    emit(StockMovementLoading());

    final result = await _inventoryRepository.getStockMovementsByProduct(event.productId);
    result.fold(
      (failure) => emit(StockMovementError(failure.message)),
      (movements) => emit(StockMovementLoaded(movements)),
    );
  }

  Future<void> _onCreateStockMovement(CreateStockMovementEvent event, Emitter<StockMovementState> emit) async {
    final result = await _createStockMovement(event.movement);
    result.fold(
      (failure) => emit(StockMovementError(failure.message)),
      (_) {
        emit(StockMovementCreated(event.movement));
        add(LoadStockMovements()); // Refresh the list
      },
    );
  }

  Future<void> _onFilterByType(FilterStockMovementsByType event, Emitter<StockMovementState> emit) async {
    emit(StockMovementLoading());
    
    final result = await _inventoryRepository.getStockMovementsByType(event.type);
    result.fold(
      (failure) => emit(StockMovementError(failure.message)),
      (movements) => emit(StockMovementLoaded(movements)),
    );
  }

  Future<void> _onFilterByDateRange(FilterStockMovementsByDateRange event, Emitter<StockMovementState> emit) async {
    emit(StockMovementLoading());
    
    final result = await _inventoryRepository.getStockMovementsByDateRange(event.startDate, event.endDate);
    result.fold(
      (failure) => emit(StockMovementError(failure.message)),
      (movements) => emit(StockMovementLoaded(movements)),
    );
  }
}