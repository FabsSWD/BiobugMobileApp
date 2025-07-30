import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement.dart';
import '../repositories/inventory_repository.dart';

class GenerateConsumptionTrendsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  GenerateConsumptionTrendsParams({
    this.startDate,
    this.endDate,
  });
}

@LazySingleton()
class GenerateConsumptionTrends implements UseCase<Map<String, double>, GenerateConsumptionTrendsParams> {
  final InventoryRepository repository;

  GenerateConsumptionTrends(this.repository);

  @override
  Future<Either<Failure, Map<String, double>>> call(GenerateConsumptionTrendsParams params) async {
    Either<Failure, List<StockMovement>> result;
    
    if (params.startDate != null && params.endDate != null) {
      result = await repository.getStockMovementsByDateRange(params.startDate!, params.endDate!);
    } else {
      result = await repository.getStockMovements();
    }
    
    return result.fold(
      (failure) => Left(failure),
      (movements) {
        final trends = StockMovementExtensions.calculateConsumptionTrends(movements);
        return Right(trends);
      },
    );
  }
}