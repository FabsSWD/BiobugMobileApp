import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement_type.dart';
import '../repositories/inventory_repository.dart';

class PredictStockoutParams {
  final String productId;
  final int daysToPredict;

  PredictStockoutParams({
    required this.productId,
    this.daysToPredict = 30,
  });
}

class StockoutPredictionResult {
  final bool willStockout;
  final int? daysUntilStockout;
  final double currentStock;
  final double averageDailyConsumption;
  final String recommendation;
  final DateTime? estimatedStockoutDate;

  StockoutPredictionResult({
    required this.willStockout,
    this.daysUntilStockout,
    required this.currentStock,
    required this.averageDailyConsumption,
    required this.recommendation,
    this.estimatedStockoutDate,
  });
}

@LazySingleton()
class PredictStockout implements UseCase<StockoutPredictionResult, PredictStockoutParams> {
  final InventoryRepository repository;

  PredictStockout(this.repository);

  @override
  Future<Either<Failure, StockoutPredictionResult>> call(PredictStockoutParams params) async {
    try {
      // Obtener item de inventario actual
      final inventoryItemResult = await repository.getInventoryItemByProductId(params.productId);
      
      return inventoryItemResult.fold(
        (failure) => Left(failure),
        (inventoryItem) async {
          if (inventoryItem == null) {
            return Left(ValidationFailure('Producto no encontrado en inventario'));
          }

          // Obtener movimientos de consumo de los últimos 90 días
          final endDate = DateTime.now();
          final startDate = endDate.subtract(const Duration(days: 90));
          
          final movementsResult = await repository.getStockMovementsByProduct(params.productId);
          
          return movementsResult.fold(
            (failure) => Left(failure),
            (movements) {
              final consumptionMovements = movements.where(
                (movement) => movement.type == StockMovementType.consumption &&
                    movement.createdAt.isAfter(startDate) &&
                    movement.createdAt.isBefore(endDate)
              ).toList();

              double averageDailyConsumption = 0;
              if (consumptionMovements.isNotEmpty) {
                final totalConsumption = consumptionMovements.fold<double>(
                  0, (sum, movement) => sum + movement.quantity
                );
                averageDailyConsumption = totalConsumption / 90;
              }

              bool willStockout = false;
              int? daysUntilStockout;
              DateTime? estimatedStockoutDate;
              String recommendation;

              if (averageDailyConsumption > 0) {
                final daysWithCurrentStock = inventoryItem.currentStock / averageDailyConsumption;
                
                if (daysWithCurrentStock <= params.daysToPredict) {
                  willStockout = true;
                  daysUntilStockout = daysWithCurrentStock.floor();
                  estimatedStockoutDate = DateTime.now().add(Duration(days: daysUntilStockout));
                  
                  if (daysUntilStockout <= 7) {
                    recommendation = 'URGENTE: El stock se agotará en $daysUntilStockout días. Realizar pedido inmediatamente.';
                  } else if (daysUntilStockout <= 14) {
                    recommendation = 'ATENCIÓN: El stock se agotará en $daysUntilStockout días. Planificar pedido pronto.';
                  } else {
                    recommendation = 'El stock se agotará en $daysUntilStockout días. Considerar hacer pedido.';
                  }
                } else {
                  recommendation = 'El stock actual es suficiente para los próximos ${params.daysToPredict} días.';
                }
              } else {
                recommendation = 'No hay datos de consumo recientes. Monitorear el uso del producto.';
              }

              return Right(StockoutPredictionResult(
                willStockout: willStockout,
                daysUntilStockout: daysUntilStockout,
                currentStock: inventoryItem.currentStock,
                averageDailyConsumption: averageDailyConsumption,
                recommendation: recommendation,
                estimatedStockoutDate: estimatedStockoutDate,
              ));
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error al predecir agotamiento de stock: $e'));
    }
  }
}