import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class GetInventoryStatistics implements UseCase<Map<String, dynamic>, NoParams> {
  final InventoryRepository repository;

  GetInventoryStatistics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getInventoryStatistics();
  }
}