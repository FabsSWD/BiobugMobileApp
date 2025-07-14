import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../error/failures.dart';

@LazySingleton()
class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) throw const FormatException();
      return Right(integer);
    } on FormatException {
      return const Left(ValidationFailure('Número inválido'));
    }
  }

  Either<Failure, double> stringToDouble(String str) {
    try {
      final number = double.parse(str);
      return Right(number);
    } on FormatException {
      return const Left(ValidationFailure('Número decimal inválido'));
    }
  }

  Either<Failure, String> validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (emailRegex.hasMatch(email)) {
      return Right(email);
    }
    return const Left(ValidationFailure('Email inválido'));
  }

  Either<Failure, String> validatePassword(String password) {
    if (password.length < 8) {
      return const Left(ValidationFailure('La contraseña debe tener al menos 8 caracteres'));
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return const Left(ValidationFailure('La contraseña debe contener al menos una mayúscula'));
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return const Left(ValidationFailure('La contraseña debe contener al menos una minúscula'));
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return const Left(ValidationFailure('La contraseña debe contener al menos un número'));
    }
    return Right(password);
  }

  Either<Failure, String> validateIdentification(String identification) {
    if (identification.isEmpty) {
      return const Left(ValidationFailure('La identificación es requerida'));
    }
    if (identification.length < 9) {
      return const Left(ValidationFailure('La identificación debe tener al menos 9 dígitos'));
    }
    if (!RegExp(r'^\d+$').hasMatch(identification)) {
      return const Left(ValidationFailure('La identificación solo debe contener números'));
    }
    return Right(identification);
  }

  Either<Failure, String> validateFullName(String fullName) {
    if (fullName.trim().isEmpty) {
      return const Left(ValidationFailure('El nombre completo es requerido'));
    }
    if (fullName.trim().length < 2) {
      return const Left(ValidationFailure('El nombre completo debe tener al menos 2 caracteres'));
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(fullName)) {
      return const Left(ValidationFailure('El nombre solo debe contener letras y espacios'));
    }
    return Right(fullName.trim());
  }
}