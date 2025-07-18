import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<Supplier>>> getAllSuppliers();
  Future<Either<Failure, Supplier>> getSupplierById(String id);
  Future<Either<Failure, Unit>> createSupplier(Supplier supplier);
  Future<Either<Failure, Unit>> updateSupplier(Supplier supplier);
  Future<Either<Failure, Unit>> deleteSupplier(String id);
  
  // Search and Filter
  Future<Either<Failure, List<Supplier>>> searchSuppliers(String query);
  Future<Either<Failure, List<Supplier>>> getActiveSuppliers();
  Future<Either<Failure, List<Supplier>>> getInactiveSuppliers();
  
  // Business Logic
  Future<Either<Failure, bool>> isSupplierInUse(String supplierId);
  Future<Either<Failure, Unit>> activateSupplier(String supplierId);
  Future<Either<Failure, Unit>> deactivateSupplier(String supplierId);
  Future<Either<Failure, List<String>>> getProductIdsBySupplier(String supplierId);
  
  // Statistics
  Future<Either<Failure, int>> getProductCountBySupplier(String supplierId);
  Future<Either<Failure, Map<String, int>>> getSupplierStatistics();
}