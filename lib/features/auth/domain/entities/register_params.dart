import 'package:equatable/equatable.dart';

class RegisterParams extends Equatable {
  final int idType;
  final int identification;
  final String fullName;
  final String email;
  final String password;

  const RegisterParams({
    required this.idType,
    required this.identification,
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [
    idType,
    identification,
    fullName,
    email,
    password,
  ];

  @override
  String toString() {
    return 'RegisterParams(idType: $idType, identification: $identification, fullName: $fullName, email: $email, password: [HIDDEN])';
  }
}