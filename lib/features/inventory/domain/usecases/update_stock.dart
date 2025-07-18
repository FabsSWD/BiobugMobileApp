import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class UpdateStock implements UseCase<Unit, InventoryItem> {
  final InventoryRepository repository;

  UpdateStock(this.repository);

  @override
  Future<Either<Failure, Unit>> call(InventoryItem params) async {
    return await repository.updateInventoryItem(params);
  }
}