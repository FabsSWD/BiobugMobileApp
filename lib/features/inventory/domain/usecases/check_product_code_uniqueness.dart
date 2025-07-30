import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

class CheckProductCodeUniquenessParams {
  final String code;
  final String? currentProductId;

  CheckProductCodeUniquenessParams({
    required this.code,
    this.currentProductId,
  });
}

@LazySingleton()
class CheckProductCodeUniqueness implements UseCase<bool, CheckProductCodeUniquenessParams> {
  final InventoryRepository repository;

  CheckProductCodeUniqueness(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckProductCodeUniquenessParams params) async {
    final result = await repository.getProducts();
    
    return result.fold(
      (failure) => Left(failure),
      (products) {
        final isUnique = ProductExtensions.isProductCodeUnique(
          params.code, 
          products, 
          params.currentProductId
        );
        return Right(isUnique);
      },
    );
  }
}