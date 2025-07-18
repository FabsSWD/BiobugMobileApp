import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

part 'auth_result_model.g.dart';

@JsonSerializable()
class AuthResultModel extends AuthResult {
  @JsonKey(name: 'token')
  final String accessToken;
  
  @JsonKey(name: 'tokenRefresh')
  final String? refreshTokenValue;
  
  @JsonKey(name: 'tokenExpiration')
  final int expirationTime;
  
  @JsonKey(name: 'userData')
  final UserModel? userModel; // ✅ Cambiar a nullable

  const AuthResultModel({
    required this.accessToken,
    this.refreshTokenValue,
    required this.expirationTime,
    this.userModel, // ✅ Cambiar a nullable
  }) : super(
          token: accessToken,
          refreshToken: refreshTokenValue ?? '', // ✅ Valor por defecto
          tokenExpiration: expirationTime,
          user: userModel, // ✅ Puede ser null
        );

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResultModelToJson(this);

  AuthResult toEntity() {
    return AuthResult(
      token: accessToken,
      refreshToken: refreshTokenValue ?? '',
      tokenExpiration: expirationTime,
      user: userModel?.toEntity(), // ✅ Manejar null
    );
  }
}