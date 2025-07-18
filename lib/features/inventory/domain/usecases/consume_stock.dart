import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement.dart';
import '../entities/stock_movement_type.dart';
import '../repositories/inventory_repository.dart';

class ConsumeStockParams {
  final String productId;
  final double quantity;
  final String? serviceId;
  final String reason;
  final String consumedBy;

  ConsumeStockParams({
    required this.productId,
    required this.quantity,
    this.serviceId,
    required this.reason,
    required this.consumedBy,
  });
}

@LazySingleton()
class ConsumeStock implements UseCase<Unit, ConsumeStockParams> {
  final InventoryRepository repository;
  final _uuid = const Uuid();

  ConsumeStock(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ConsumeStockParams params) async {
    try {
      // Obtener el item de inventario del producto
      final inventoryItemResult = await repository.getInventoryItemByProductId(params.productId);
      
      return inventoryItemResult.fold(
        (failure) => Left(failure),
        (inventoryItem) async {
          if (inventoryItem == null) {
            return Left(ValidationFailure('Producto no encontrado en inventario'));
          }

          // Verificar que hay suficiente stock
          if (inventoryItem.currentStock < params.quantity) {
            return Left(ValidationFailure(
              'Stock insuficiente. Disponible: ${inventoryItem.currentStock}, Solicitado: ${params.quantity}'
            ));
          }

          // Obtener el producto para calcular costo
          final productResult = await repository.getProductById(params.productId);
          
          return productResult.fold(
            (failure) => Left(failure),
            (product) async {
              // Actualizar el stock
              final updatedItem = inventoryItem.copyWith(
                currentStock: inventoryItem.currentStock - params.quantity,
                lastUpdated: DateTime.now(),
                lastUpdatedBy: params.consumedBy,
              );

              final updateResult = await repository.updateInventoryItem(updatedItem);
              
              return updateResult.fold(
                (failure) => Left(failure),
                (_) async {
                  // Crear movimiento de stock
                  final movement = StockMovement(
                    id: _uuid.v4(),
                    inventoryItemId: inventoryItem.id,
                    productId: params.productId,
                    type: StockMovementType.consumption,
                    quantity: params.quantity,
                    unitCost: product.unitCost,
                    totalCost: product.unitCost * params.quantity,
                    reason: params.reason,
                    serviceId: params.serviceId,
                    createdAt: DateTime.now(),
                    createdBy: params.consumedBy,
                  );

                  final movementResult = await repository.createStockMovement(movement);
                  
                  return movementResult.fold(
                    (failure) => Left(failure),
                    (_) => const Right(unit),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error al consumir stock: $e'));
    }
  }
}