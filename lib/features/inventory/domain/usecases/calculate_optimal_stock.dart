import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement_type.dart';
import '../repositories/inventory_repository.dart';

class CalculateOptimalStockParams {
  final String productId;
  final int daysToAnalyze;
  final double safetyFactor; // Factor de seguridad (ej: 1.2 para 20% extra)

  CalculateOptimalStockParams({
    required this.productId,
    this.daysToAnalyze = 90,
    this.safetyFactor = 1.2,
  });
}

class OptimalStockResult {
  final double recommendedMinimumStock;
  final double recommendedMaximumStock;
  final double averageDailyConsumption;
  final int leadTimeDays;
  final double reorderPoint;
  final String recommendation;

  OptimalStockResult({
    required this.recommendedMinimumStock,
    required this.recommendedMaximumStock,
    required this.averageDailyConsumption,
    required this.leadTimeDays,
    required this.reorderPoint,
    required this.recommendation,
  });
}

@LazySingleton()
class CalculateOptimalStock implements UseCase<OptimalStockResult, CalculateOptimalStockParams> {
  final InventoryRepository repository;

  CalculateOptimalStock(this.repository);

  @override
  Future<Either<Failure, OptimalStockResult>> call(CalculateOptimalStockParams params) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: params.daysToAnalyze));

      // Obtener movimientos de consumo del producto
      final movementsResult = await repository.getStockMovementsByProduct(params.productId);
      
      return movementsResult.fold(
        (failure) => Left(failure),
        (movements) {
          final consumptionMovements = movements.where(
            (movement) => movement.type == StockMovementType.consumption &&
                movement.createdAt.isAfter(startDate) &&
                movement.createdAt.isBefore(endDate)
          ).toList();

          if (consumptionMovements.isEmpty) {
            return Right(OptimalStockResult(
              recommendedMinimumStock: 10, // Stock mínimo por defecto
              recommendedMaximumStock: 50, // Stock máximo por defecto
              averageDailyConsumption: 0,
              leadTimeDays: 7, // Lead time por defecto
              reorderPoint: 15,
              recommendation: 'No hay datos suficientes de consumo. Se sugieren valores por defecto.',
            ));
          }

          // Calcular consumo promedio diario
          final totalConsumption = consumptionMovements.fold<double>(
            0, (sum, movement) => sum + movement.quantity
          );
          final averageDailyConsumption = totalConsumption / params.daysToAnalyze;

          // Estimrar lead time basado en movimientos de compra
          final purchaseMovements = movements.where(
            (movement) => movement.type == StockMovementType.purchase
          ).toList();

          int leadTimeDays = 7; // Default
          if (purchaseMovements.length > 1) {
            // Calcular promedio entre compras
            purchaseMovements.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            int totalDaysBetweenPurchases = 0;
            for (int i = 1; i < purchaseMovements.length; i++) {
              totalDaysBetweenPurchases += purchaseMovements[i].createdAt
                  .difference(purchaseMovements[i-1].createdAt).inDays;
            }
            leadTimeDays = (totalDaysBetweenPurchases / (purchaseMovements.length - 1)).round();
            leadTimeDays = leadTimeDays.clamp(3, 30); // Entre 3 y 30 días
          }

          // Calcular stocks óptimos
          final safetyStock = averageDailyConsumption * leadTimeDays * (params.safetyFactor - 1);
          final reorderPoint = (averageDailyConsumption * leadTimeDays) + safetyStock;
          final recommendedMinimumStock = reorderPoint;
          final recommendedMaximumStock = recommendedMinimumStock + (averageDailyConsumption * 30); // 30 días adicionales

          // Generar recomendación
          String recommendation;
          if (averageDailyConsumption > 0) {
            final daysOfStock = recommendedMaximumStock / averageDailyConsumption;
            recommendation = 'Basado en el análisis de $params.daysToAnalyze días, se recomienda mantener entre '
                '${recommendedMinimumStock.toStringAsFixed(1)} y ${recommendedMaximumStock.toStringAsFixed(1)} unidades. '
                'Esto proporcionará aproximadamente ${daysOfStock.toStringAsFixed(0)} días de inventario.';
          } else {
            recommendation = 'El producto tiene muy bajo consumo. Considerar revisar la necesidad del producto.';
          }

          return Right(OptimalStockResult(
            recommendedMinimumStock: recommendedMinimumStock,
            recommendedMaximumStock: recommendedMaximumStock,
            averageDailyConsumption: averageDailyConsumption,
            leadTimeDays: leadTimeDays,
            reorderPoint: reorderPoint,
            recommendation: recommendation,
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error al calcular stock óptimo: $e'));
    }
  }
}