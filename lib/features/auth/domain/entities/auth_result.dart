import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final String token;
  final String refreshToken;
  final int tokenExpiration;
  final User? user; // ✅ Cambiar a nullable

  const AuthResult({
    required this.token,
    required this.refreshToken,
    required this.tokenExpiration,
    this.user, // ✅ Nullable
  });

  @override
  List<Object?> get props => [
    token,
    refreshToken,
    tokenExpiration,
    user,
  ];

  @override
  String toString() {
    return 'AuthResult(token: ${token.substring(0, 10)}..., refreshToken: ${refreshToken.isNotEmpty ? '${refreshToken.substring(0, 10)}...' : 'empty'}, tokenExpiration: $tokenExpiration, user: $user)';
  }
}