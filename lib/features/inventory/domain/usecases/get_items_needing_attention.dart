import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class GetItemsNeedingAttention implements UseCase<List<InventoryItem>, NoParams> {
  final InventoryRepository repository;

  GetItemsNeedingAttention(this.repository);

  @override
  Future<Either<Failure, List<InventoryItem>>> call(NoParams params) async {
    final result = await repository.getInventoryItems();
    
    return result.fold(
      (failure) => Left(failure),
      (items) {
        final itemsNeedingAttention = items.where((item) => item.needsAttention).toList();
        return Right(itemsNeedingAttention);
      },
    );
  }
}