import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class UpdateProduct implements UseCase<Unit, Product> {
  final InventoryRepository repository;

  UpdateProduct(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Product params) async {
    return await repository.updateProduct(params);
  }
}