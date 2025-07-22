import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/supplier.dart';

@LazySingleton()
class ValidateSupplier implements UseCase<Unit, Supplier> {
  @override
  Future<Either<Failure, Unit>> call(Supplier params) async {
    // Validar nombre
    if (params.name.trim().isEmpty) {
      return Left(ValidationFailure('El nombre del proveedor es requerido'));
    }

    if (params.name.length < 2) {
      return Left(ValidationFailure('El nombre del proveedor debe tener al menos 2 caracteres'));
    }

    // Validar persona de contacto
    if (params.contactPerson.trim().isEmpty) {
      return Left(ValidationFailure('La persona de contacto es requerida'));
    }

    // Validar email
    if (params.email.trim().isEmpty) {
      return Left(ValidationFailure('El email es requerido'));
    }

    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure('El formato del email no es válido'));
    }

    // Validar teléfono
    if (params.phone.trim().isEmpty) {
      return Left(ValidationFailure('El teléfono es requerido'));
    }

    if (!_isValidPhone(params.phone)) {
      return Left(ValidationFailure('El formato del teléfono no es válido'));
    }

    // Validar dirección
    if (params.address.trim().isEmpty) {
      return Left(ValidationFailure('La dirección es requerida'));
    }

    if (params.address.length < 10) {
      return Left(ValidationFailure('La dirección debe ser más específica'));
    }

    // Validar website si se proporciona
    if (params.website != null && params.website!.isNotEmpty) {
      if (!_isValidWebsite(params.website!)) {
        return Left(ValidationFailure('El formato del sitio web no es válido'));
      }
    }

    return const Right(unit);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Permitir números con espacios, guiones y paréntesis
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{7,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  bool _isValidWebsite(String website) {
    final websiteRegex = RegExp(r'^https?:\/\/.+\..+');
    return websiteRegex.hasMatch(website);
  }
}