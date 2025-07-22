import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_item.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

class ReorderSuggestion {
  final Product product;
  final InventoryItem inventoryItem;
  final double suggestedQuantity;
  final double estimatedCost;
  final String urgency; // 'critical', 'high', 'medium', 'low'
  final String reason;
  final int daysUntilStockout;

  ReorderSuggestion({
    required this.product,
    required this.inventoryItem,
    required this.suggestedQuantity,
    required this.estimatedCost,
    required this.urgency,
    required this.reason,
    required this.daysUntilStockout,
  });
}

@LazySingleton()
class GenerateReorderSuggestions implements UseCase<List<ReorderSuggestion>, NoParams> {
  final InventoryRepository repository;

  GenerateReorderSuggestions(this.repository);

  @override
  Future<Either<Failure, List<ReorderSuggestion>>> call(NoParams params) async {
    try {
      // Obtener todos los items de inventario
      final inventoryItemsResult = await repository.getInventoryItems();
      
      return inventoryItemsResult.fold(
        (failure) => Left(failure),
        (inventoryItems) async {
          final suggestions = <ReorderSuggestion>[];

          for (final item in inventoryItems) {
            // Solo considerar items que necesitan reorden
            if (item.currentStock > item.minimumStock) continue;

            // Obtener el producto
            final productResult = await repository.getProductById(item.productId);
            
            await productResult.fold(
              (failure) async => {}, // Ignorar productos que no se pueden obtener
              (product) async {
                if (!product.isActive) return; // Ignorar productos inactivos

                // Calcular cantidad sugerida (llevar al stock máximo)
                final suggestedQuantity = item.maximumStock - item.currentStock;
                final estimatedCost = suggestedQuantity * product.unitCost;

                // Determinar urgencia
                String urgency;
                String reason;
                int daysUntilStockout = 0;

                if (item.isOutOfStock) {
                  urgency = 'critical';
                  reason = 'Producto sin stock';
                } else if (item.currentStock <= (item.minimumStock * 0.5)) {
                  urgency = 'high';
                  reason = 'Stock muy bajo (menos del 50% del mínimo)';
                  daysUntilStockout = _estimateDaysUntilStockout(item);
                } else {
                  urgency = 'medium';
                  reason = 'Stock por debajo del mínimo';
                  daysUntilStockout = _estimateDaysUntilStockout(item);
                }

                suggestions.add(ReorderSuggestion(
                  product: product,
                  inventoryItem: item,
                  suggestedQuantity: suggestedQuantity,
                  estimatedCost: estimatedCost,
                  urgency: urgency,
                  reason: reason,
                  daysUntilStockout: daysUntilStockout,
                ));
              },
            );
          }

          // Ordenar por urgencia (critical > high > medium > low)
          suggestions.sort((a, b) {
            final urgencyOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
            final aOrder = urgencyOrder[a.urgency] ?? 3;
            final bOrder = urgencyOrder[b.urgency] ?? 3;
            
            if (aOrder != bOrder) {
              return aOrder.compareTo(bOrder);
            }
            
            // Si tienen la misma urgencia, ordenar por días hasta agotamiento
            return a.daysUntilStockout.compareTo(b.daysUntilStockout);
          });

          return Right(suggestions);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error al generar sugerencias de reorden: $e'));
    }
  }

  int _estimateDaysUntilStockout(InventoryItem item) {
    // Estimación simple basada en el stock actual y mínimo
    // En una implementación real, se usarían los datos históricos de consumo
    if (item.currentStock <= 0) return 0;
    
    // Asumir un consumo diario promedio basado en la diferencia entre stock máximo y mínimo
    final estimatedDailyConsumption = (item.maximumStock - item.minimumStock) / 30; // 30 días de consumo
    
    if (estimatedDailyConsumption <= 0) return 999; // Si no se puede estimar, retornar un valor alto
    
    return (item.currentStock / estimatedDailyConsumption).floor();
  }
}