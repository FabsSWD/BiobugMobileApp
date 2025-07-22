import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';

@LazySingleton()
class ValidateProductData implements UseCase<Unit, Product> {
  @override
  Future<Either<Failure, Unit>> call(Product params) async {
    // Validar nombre del producto
    if (params.name.trim().isEmpty) {
      return Left(ValidationFailure('El nombre del producto es requerido'));
    }

    if (params.name.length < 3) {
      return Left(ValidationFailure('El nombre del producto debe tener al menos 3 caracteres'));
    }

    // Validar ingrediente activo
    if (params.activeIngredient.trim().isEmpty) {
      return Left(ValidationFailure('El ingrediente activo es requerido'));
    }

    // Validar concentración
    if (params.concentration <= 0) {
      return Left(ValidationFailure('La concentración debe ser mayor a 0'));
    }

    if (params.concentration > 100) {
      return Left(ValidationFailure('La concentración no puede ser mayor a 100%'));
    }

    // Validar registro sanitario
    if (params.sanitaryRegistryNumber.trim().isEmpty) {
      return Left(ValidationFailure('El número de registro sanitario es requerido'));
    }

    // Validar fecha de expiración
    if (params.expirationDate.isBefore(DateTime.now())) {
      return Left(ValidationFailure('La fecha de expiración no puede ser anterior a la fecha actual'));
    }

    // Validar costos
    if (params.unitCost <= 0) {
      return Left(ValidationFailure('El costo unitario debe ser mayor a 0'));
    }

    if (params.applicationCost < 0) {
      return Left(ValidationFailure('El costo de aplicación no puede ser negativo'));
    }

    // Validar unidad
    if (params.unit.trim().isEmpty) {
      return Left(ValidationFailure('La unidad de medida es requerida'));
    }

    // Validar fabricante
    if (params.manufacturer.trim().isEmpty) {
      return Left(ValidationFailure('El fabricante es requerido'));
    }

    // Validar proveedor
    if (params.supplier.trim().isEmpty) {
      return Left(ValidationFailure('El proveedor es requerido'));
    }

    return const Right(unit);
  }
}