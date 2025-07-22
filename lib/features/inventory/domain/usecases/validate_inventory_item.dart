import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_item.dart';

@LazySingleton()
class ValidateInventoryItem implements UseCase<Unit, InventoryItem> {
  @override
  Future<Either<Failure, Unit>> call(InventoryItem params) async {
    // Validar que existe el producto
    if (params.productId.trim().isEmpty) {
      return Left(ValidationFailure('El ID del producto es requerido'));
    }

    // Validar stock actual
    if (params.currentStock < 0) {
      return Left(ValidationFailure('El stock actual no puede ser negativo'));
    }

    // Validar stock mínimo
    if (params.minimumStock < 0) {
      return Left(ValidationFailure('El stock mínimo no puede ser negativo'));
    }

    // Validar stock máximo
    if (params.maximumStock <= 0) {
      return Left(ValidationFailure('El stock máximo debe ser mayor a 0'));
    }

    // Validar que el stock máximo sea mayor al mínimo
    if (params.maximumStock <= params.minimumStock) {
      return Left(ValidationFailure('El stock máximo debe ser mayor al stock mínimo'));
    }

    // Validar ubicación
    if (params.location.trim().isEmpty) {
      return Left(ValidationFailure('La ubicación es requerida'));
    }

    // Validar número de lote
    if (params.batchNumber.trim().isEmpty) {
      return Left(ValidationFailure('El número de lote es requerido'));
    }

    // Validar que el stock actual no exceda significativamente el máximo
    if (params.currentStock > params.maximumStock * 1.5) {
      return Left(ValidationFailure('El stock actual excede significativamente el stock máximo recomendado'));
    }

    // Validar usuario que actualizó
    if (params.lastUpdatedBy.trim().isEmpty) {
      return Left(ValidationFailure('El usuario que actualizó es requerido'));
    }

    return const Right(unit);
  }
}