import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/supplier.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class AddSupplier implements UseCase<Unit, Supplier> {
  final InventoryRepository repository;

  AddSupplier(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Supplier params) async {
    return await repository.addSupplier(params);
  }
}