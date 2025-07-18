import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_alert.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class GetInventoryAlerts implements UseCase<List<InventoryAlert>, NoParams> {
  final InventoryRepository repository;

  GetInventoryAlerts(this.repository);

  @override
  Future<Either<Failure, List<InventoryAlert>>> call(NoParams params) async {
    return await repository.getInventoryAlerts();
  }
}