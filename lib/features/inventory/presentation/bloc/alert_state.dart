import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_alert.dart';

abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<InventoryAlert> alerts;

  const AlertLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class AlertUpdated extends AlertState {
  final InventoryAlert alert;

  const AlertUpdated(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AlertError extends AlertState {
  final String message;

  const AlertError(this.message);

  @override
  List<Object?> get props => [message];
}