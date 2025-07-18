import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement_type.dart';
import '../repositories/inventory_repository.dart';

class CalculateProductCostParams {
  final String productId;
  final double quantity;

  CalculateProductCostParams({
    required this.productId,
    required this.quantity,
  });
}

class ProductCostResult {
  final double unitCost;
  final double totalCost;
  final double averageCost;

  ProductCostResult({
    required this.unitCost,
    required this.totalCost,
    required this.averageCost,
  });
}

@LazySingleton()
class CalculateProductCost implements UseCase<ProductCostResult, CalculateProductCostParams> {
  final InventoryRepository repository;

  CalculateProductCost(this.repository);

  @override
  Future<Either<Failure, ProductCostResult>> call(CalculateProductCostParams params) async {
    try {
      // Obtener el producto
      final productResult = await repository.getProductById(params.productId);
      
      return productResult.fold(
        (failure) => Left(failure),
        (product) async {
          // Obtener movimientos de compra para calcular costo promedio
          final movementsResult = await repository.getStockMovementsByProduct(params.productId);
          
          return movementsResult.fold(
            (failure) => Left(failure),
            (movements) {
              // Filtrar solo movimientos de compra
              final purchaseMovements = movements.where(
                (movement) => movement.type == StockMovementType.purchase
              ).toList();

              double averageCost = product.unitCost;
              
              if (purchaseMovements.isNotEmpty) {
                // Calcular costo promedio ponderado
                double totalCost = 0;
                double totalQuantity = 0;
                
                for (final movement in purchaseMovements) {
                  totalCost += movement.totalCost;
                  totalQuantity += movement.quantity;
                }
                
                if (totalQuantity > 0) {
                  averageCost = totalCost / totalQuantity;
                }
              }

              final result = ProductCostResult(
                unitCost: product.unitCost,
                totalCost: averageCost * params.quantity,
                averageCost: averageCost,
              );

              return Right(result);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error al calcular costo del producto: $e'));
    }
  }
}