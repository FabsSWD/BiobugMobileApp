import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement.dart';
import '../entities/inventory_item.dart';
import '../entities/stock_movement_type.dart';
import '../repositories/inventory_repository.dart';

class ValidateStockMovementParams {
  final StockMovement movement;
  final InventoryItem? inventoryItem; // Opcional si ya se tiene

  ValidateStockMovementParams({
    required this.movement,
    this.inventoryItem,
  });
}

@LazySingleton()
class ValidateStockMovement implements UseCase<Unit, ValidateStockMovementParams> {
  final InventoryRepository repository;

  ValidateStockMovement(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ValidateStockMovementParams params) async {
    try {
      final movement = params.movement;

      // Validaciones básicas (reutilizando las existentes)
      if (movement.quantity <= 0) {
        return Left(ValidationFailure('La cantidad debe ser mayor a cero'));
      }

      if (movement.unitCost < 0) {
        return Left(ValidationFailure('El costo unitario no puede ser negativo'));
      }

      // Obtener item de inventario si no se proporcionó
      InventoryItem? inventoryItem = params.inventoryItem;
      if (inventoryItem == null) {
        final itemResult = await repository.getInventoryItemById(movement.inventoryItemId);
        itemResult.fold(
          (failure) => throw Exception(failure.message),
          (item) => inventoryItem = item,
        );
      }

      if (inventoryItem == null) {
        return Left(ValidationFailure('Item de inventario no encontrado'));
      }

      // Usar el método estático de la extensión
      if (!StockMovementExtensions.isValidMovement(movement, inventoryItem!)) {
        return Left(ValidationFailure(
          'Movimiento inválido: Stock insuficiente. Disponible: ${inventoryItem!.currentStock}, Solicitado: ${movement.quantity}'
        ));
      }

      // Validaciones específicas por tipo (mantener las existentes)
      switch (movement.type) {
        case StockMovementType.consumption:
          if (movement.serviceId == null || movement.serviceId!.trim().isEmpty) {
            return Left(ValidationFailure('El ID del servicio es requerido para movimientos de consumo'));
          }
          break;
        case StockMovementType.purchase:
          if (movement.reference == null || movement.reference!.trim().isEmpty) {
            return Left(ValidationFailure('La referencia (factura/orden) es requerida para compras'));
          }
          break;
        case StockMovementType.transfer:
          if (movement.notes == null || movement.notes!.trim().isEmpty) {
            return Left(ValidationFailure('Las notas son requeridas para transferencias (ubicación destino)'));
          }
          break;
        default:
          break;
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al validar movimiento de stock: $e'));
    }
  }
}