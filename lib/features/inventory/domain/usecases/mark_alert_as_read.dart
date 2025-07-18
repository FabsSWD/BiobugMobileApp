import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

class MarkAlertAsReadParams {
  final String alertId;

  MarkAlertAsReadParams({required this.alertId});
}

@LazySingleton()
class MarkAlertAsRead implements UseCase<Unit, MarkAlertAsReadParams> {
  final InventoryRepository repository;

  MarkAlertAsRead(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkAlertAsReadParams params) async {
    return await repository.markAlertAsRead(params.alertId);
  }
}