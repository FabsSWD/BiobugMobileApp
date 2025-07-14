import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final String token;
  final String refreshToken;
  final int tokenExpiration;
  final User user;

  const AuthResult({
    required this.token,
    required this.refreshToken,
    required this.tokenExpiration,
    required this.user,
  });

  @override
  List<Object> get props => [
    token,
    refreshToken,
    tokenExpiration,
    user,
  ];

  @override
  String toString() {
    return 'AuthResult(token: ${token.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}..., tokenExpiration: $tokenExpiration, user: $user)';
  }
}