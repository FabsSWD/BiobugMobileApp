import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

class GetExpiringProductsParams {
  final int daysThreshold;

  GetExpiringProductsParams({required this.daysThreshold});
}

@LazySingleton()
class GetExpiringProducts implements UseCase<List<Product>, GetExpiringProductsParams> {
  final InventoryRepository repository;

  GetExpiringProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetExpiringProductsParams params) async {
    return await repository.getExpiringProducts(params.daysThreshold);
  }
}