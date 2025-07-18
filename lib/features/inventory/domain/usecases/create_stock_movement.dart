import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class CreateStockMovement implements UseCase<Unit, StockMovement> {
  final InventoryRepository repository;

  CreateStockMovement(this.repository);

  @override
  Future<Either<Failure, Unit>> call(StockMovement params) async {
    return await repository.createStockMovement(params);
  }
}