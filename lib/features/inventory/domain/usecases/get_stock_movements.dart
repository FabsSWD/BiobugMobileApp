import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_movement.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class GetStockMovements implements UseCase<List<StockMovement>, NoParams> {
  final InventoryRepository repository;

  GetStockMovements(this.repository);

  @override
  Future<Either<Failure, List<StockMovement>>> call(NoParams params) async {
    return await repository.getStockMovements();
  }
}