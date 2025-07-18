import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ReportRepository {
  // Inventory Reports
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStatusReport();
  Future<Either<Failure, Map<String, dynamic>>> getStockValueReport();
  Future<Either<Failure, Map<String, dynamic>>> getLowStockReport();
  Future<Either<Failure, Map<String, dynamic>>> getExpirationReport();
  
  // Movement Reports
  Future<Either<Failure, Map<String, dynamic>>> getStockMovementReport(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getConsumptionReport(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getPurchaseReport(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getWasteReport(DateTime startDate, DateTime endDate);
  
  // Product Reports
  Future<Either<Failure, Map<String, dynamic>>> getProductUsageReport(String productId, DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopConsumedProducts(int limit, DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopCostlyProducts(int limit, DateTime startDate, DateTime endDate);
  
  // Cost Analysis
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysisReport(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getCostByProduct(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getCostBySupplier(DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getCostTrends(DateTime startDate, DateTime endDate);
  
  // Performance Reports
  Future<Either<Failure, Map<String, dynamic>>> getInventoryTurnoverReport();
  Future<Either<Failure, Map<String, dynamic>>> getStockAccuracyReport();
  Future<Either<Failure, Map<String, dynamic>>> getSupplierPerformanceReport();
  
  // Export Functions
  Future<Either<Failure, String>> exportReportToPdf(String reportType, Map<String, dynamic> data);
  Future<Either<Failure, String>> exportReportToExcel(String reportType, Map<String, dynamic> data);
  Future<Either<Failure, String>> exportReportToCsv(String reportType, Map<String, dynamic> data);
}