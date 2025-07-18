import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

class DeleteProductParams {
  final String productId;

  DeleteProductParams({required this.productId});
}

@LazySingleton()
class DeleteProduct implements UseCase<Unit, DeleteProductParams> {
  final InventoryRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteProductParams params) async {
    return await repository.deleteProduct(params.productId);
  }
}