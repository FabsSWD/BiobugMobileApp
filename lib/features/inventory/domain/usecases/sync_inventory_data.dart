import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class SyncInventoryData implements UseCase<Unit, NoParams> {
  final InventoryRepository repository;

  SyncInventoryData(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.syncWithRemote();
  }
}