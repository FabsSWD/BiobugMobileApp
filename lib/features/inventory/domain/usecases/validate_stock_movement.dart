import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement.dart';
import '../entities/stock_movement_type.dart';

@LazySingleton()
class ValidateStockMovement implements UseCase<Unit, StockMovement> {
  @override
  Future<Either<Failure, Unit>> call(StockMovement params) async {
    // Validar que existe el item de inventario
    if (params.inventoryItemId.trim().isEmpty) {
      return Left(ValidationFailure('El ID del item de inventario es requerido'));
    }

    // Validar que existe el producto
    if (params.productId.trim().isEmpty) {
      return Left(ValidationFailure('El ID del producto es requerido'));
    }

    // Validar cantidad
    if (params.quantity <= 0) {
      return Left(ValidationFailure('La cantidad debe ser mayor a 0'));
    }

    // Validar cantidad máxima razonable
    if (params.quantity > 10000) {
      return Left(ValidationFailure('La cantidad parece excesiva, por favor verificar'));
    }

    // Validar costo unitario
    if (params.unitCost <= 0) {
      return Left(ValidationFailure('El costo unitario debe ser mayor a 0'));
    }

    // Validar costo total
    if (params.totalCost <= 0) {
      return Left(ValidationFailure('El costo total debe ser mayor a 0'));
    }

    // Validar coherencia entre cantidad, costo unitario y costo total
    final expectedTotalCost = params.quantity * params.unitCost;
    final difference = (params.totalCost - expectedTotalCost).abs();
    const tolerance = 0.01; // Tolerancia de 1 centavo

    if (difference > tolerance) {
      return Left(ValidationFailure('El costo total no coincide con la cantidad multiplicada por el costo unitario'));
    }

    // Validar razón del movimiento
    if (params.reason.trim().isEmpty) {
      return Left(ValidationFailure('La razón del movimiento es requerida'));
    }

    if (params.reason.length < 5) {
      return Left(ValidationFailure('La razón del movimiento debe tener al menos 5 caracteres'));
    }

    // Validar usuario que creó el movimiento
    if (params.createdBy.trim().isEmpty) {
      return Left(ValidationFailure('El usuario que creó el movimiento es requerido'));
    }

    // Validaciones específicas por tipo de movimiento
    switch (params.type) {
      case StockMovementType.consumption:
        if (params.serviceId == null || params.serviceId!.trim().isEmpty) {
          return Left(ValidationFailure('El ID del servicio es requerido para movimientos de consumo'));
        }
        break;
      case StockMovementType.purchase:
        if (params.reference == null || params.reference!.trim().isEmpty) {
          return Left(ValidationFailure('La referencia (factura/orden) es requerida para compras'));
        }
        break;
      case StockMovementType.transfer:
        if (params.notes == null || params.notes!.trim().isEmpty) {
          return Left(ValidationFailure('Las notas son requeridas para transferencias (ubicación destino)'));
        }
        break;
      default:
        break;
    }

    return const Right(unit);
  }
}