import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_alert_priority.dart';
import '../../domain/entities/inventory_alert_type.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlerts extends AlertEvent {}

class FilterAlertsByPriority extends AlertEvent {
  final InventoryAlertPriority priority;

  const FilterAlertsByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}

class FilterAlertsByType extends AlertEvent {
  final InventoryAlertType type;

  const FilterAlertsByType(this.type);

  @override
  List<Object?> get props => [type];
}

class MarkAlertAsReadEvent extends AlertEvent {
  final String alertId;

  const MarkAlertAsReadEvent(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class DismissAlert extends AlertEvent {
  final String alertId;

  const DismissAlert(this.alertId);

  @override
  List<Object?> get props => [alertId];
}