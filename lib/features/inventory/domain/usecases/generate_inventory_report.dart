import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

class GenerateInventoryReportParams {
  final DateTime startDate;
  final DateTime endDate;
  final String reportType; // 'consumption', 'stock_value', 'movement', etc.

  GenerateInventoryReportParams({
    required this.startDate,
    required this.endDate,
    required this.reportType,
  });
}

@LazySingleton()
class GenerateInventoryReport implements UseCase<Map<String, dynamic>, GenerateInventoryReportParams> {
  final InventoryRepository repository;

  GenerateInventoryReport(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GenerateInventoryReportParams params) async {
    switch (params.reportType.toLowerCase()) {
      case 'consumption':
        return await repository.getConsumptionReport(params.startDate, params.endDate);
      case 'stock_value':
        return await repository.getStockValueReport();
      case 'statistics':
        return await repository.getInventoryStatistics();
      default:
        return Left(ValidationFailure('Tipo de reporte no válido: ${params.reportType}'));
    }
  }
}