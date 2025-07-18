import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

class SearchProductsParams {
  final String query;

  SearchProductsParams({required this.query});
}

@LazySingleton()
class SearchProducts implements UseCase<List<Product>, SearchProductsParams> {
  final InventoryRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(SearchProductsParams params) async {
    if (params.query.trim().isEmpty) {
      return const Right([]);
    }
    
    return await repository.searchProducts(params.query);
  }
}