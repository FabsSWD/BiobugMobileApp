import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_item.dart';
import '../entities/product.dart';

class CalculateInventoryValueParams {
  final List<InventoryItem> items;
  final List<Product> products;

  CalculateInventoryValueParams({
    required this.items,
    required this.products,
  });
}

@LazySingleton()
class CalculateInventoryValue implements UseCase<double, CalculateInventoryValueParams> {
  @override
  Future<Either<Failure, double>> call(CalculateInventoryValueParams params) async {
    try {
      double totalValue = 0;
      
      for (final item in params.items) {
        final product = params.products.where((p) => p.id == item.productId).firstOrNull;
        if (product != null) {
          totalValue += item.currentStock * product.unitCost;
        }
      }
      
      return Right(totalValue);
    } catch (e) {
      return Left(ServerFailure('Error al calcular valor del inventario: $e'));
    }
  }
}