import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_inventory_alerts.dart';
import '../../domain/usecases/mark_alert_as_read.dart' as mark_alert_usecase;
import '../../domain/repositories/inventory_repository.dart';
import 'alert_event.dart';
import 'alert_state.dart';

@Injectable()
class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final GetInventoryAlerts _getInventoryAlerts;
  final mark_alert_usecase.MarkAlertAsRead _markAlertAsRead;
  final InventoryRepository _inventoryRepository;

  AlertBloc(
    this._getInventoryAlerts,
    this._markAlertAsRead,
    this._inventoryRepository,
  ) : super(AlertInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<FilterAlertsByPriority>(_onFilterByPriority);
    on<FilterAlertsByType>(_onFilterByType);
    on<MarkAlertAsReadEvent>(_onMarkAlertAsRead);
    on<DismissAlert>(_onDismissAlert);
  }

  Future<void> _onLoadAlerts(LoadAlerts event, Emitter<AlertState> emit) async {
    emit(AlertLoading());

    final result = await _getInventoryAlerts(NoParams());
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) => emit(AlertLoaded(alerts)),
    );
  }

  Future<void> _onFilterByPriority(FilterAlertsByPriority event, Emitter<AlertState> emit) async {
    emit(AlertLoading());
    
    final result = await _inventoryRepository.getAlertsByPriority(event.priority);
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) => emit(AlertLoaded(alerts)),
    );
  }

  Future<void> _onFilterByType(FilterAlertsByType event, Emitter<AlertState> emit) async {
    emit(AlertLoading());
    
    final result = await _inventoryRepository.getAlertsByType(event.type);
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) => emit(AlertLoaded(alerts)),
    );
  }

  Future<void> _onMarkAlertAsRead(MarkAlertAsReadEvent event, Emitter<AlertState> emit) async {
    final result = await _markAlertAsRead(mark_alert_usecase.MarkAlertAsReadParams(alertId: event.alertId));
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (_) => add(LoadAlerts()), // Refresh the list
    );
  }

  Future<void> _onDismissAlert(DismissAlert event, Emitter<AlertState> emit) async {
    // Using markAlertAsResolved as "dismiss" functionality
    final result = await _inventoryRepository.markAlertAsResolved(event.alertId, 'user');
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (_) => add(LoadAlerts()), // Refresh the list
    );
  }
}