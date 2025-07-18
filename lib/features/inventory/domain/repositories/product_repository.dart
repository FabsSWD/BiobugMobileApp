import 'package:biobug_mobile_app/features/inventory/domain/entities/toxicological_classification.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Unit>> createProduct(Product product);
  Future<Either<Failure, Unit>> updateProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(String id);
  Future<Either<Failure, List<Product>>> searchProducts({
    String? query,
    String? activeIngredient,
    ToxicologicalClassification? classification,
    String? manufacturer,
    String? supplier,
    bool? isActive,
  });
  Future<Either<Failure, List<Product>>> getProductsBySupplier(String supplierId);
  Future<Either<Failure, List<Product>>> getExpiringProducts(int daysThreshold);
  Future<Either<Failure, List<Product>>> getExpiredProducts();
  Future<Either<Failure, List<Product>>> getActiveProducts();
  Future<Either<Failure, bool>> isProductInUse(String productId);
  Future<Either<Failure, Unit>> activateProduct(String productId);
  Future<Either<Failure, Unit>> deactivateProduct(String productId);
}