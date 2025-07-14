import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userId;
  final int idType;
  final int identification;
  final String fullName;
  final String email;

  const User({
    required this.userId,
    required this.idType,
    required this.identification,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object> get props => [
    userId,
    idType,
    identification,
    fullName,
    email,
  ];

  @override
  String toString() {
    return 'User(userId: $userId, idType: $idType, identification: $identification, fullName: $fullName, email: $email)';
  }

  User copyWith({
    String? userId,
    int? idType,
    int? identification,
    String? fullName,
    String? email,
  }) {
    return User(
      userId: userId ?? this.userId,
      idType: idType ?? this.idType,
      identification: identification ?? this.identification,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }
}