import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String username; // Email or identification number
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() {
    return 'LoginParams(username: $username, password: [HIDDEN])';
  }
}