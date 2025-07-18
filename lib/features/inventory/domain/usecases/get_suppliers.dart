import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/supplier.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class GetSuppliers implements UseCase<List<Supplier>, NoParams> {
  final InventoryRepository repository;

  GetSuppliers(this.repository);

  @override
  Future<Either<Failure, List<Supplier>>> call(NoParams params) async {
    return await repository.getSuppliers();
  }
}