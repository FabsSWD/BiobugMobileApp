import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

part 'auth_result_model.g.dart';

@JsonSerializable()
class AuthResultModel extends AuthResult {
  @JsonKey(name: 'token')
  final String accessToken;
  
  @JsonKey(name: 'tokenExpiration')
  final int expirationTime;
  
  @JsonKey(name: 'userData')
  final UserModel userModel;

  const AuthResultModel({
    required this.accessToken,
    required this.expirationTime,
    required this.userModel,
  }) : super(
          token: accessToken,
          refreshToken: accessToken, // Use same token as refresh for now
          tokenExpiration: expirationTime,
          user: userModel,
        );

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResultModelToJson(this);

  AuthResult toEntity() {
    return AuthResult(
      token: accessToken,
      refreshToken: accessToken, // Use same token as refresh for now
      tokenExpiration: expirationTime,
      user: userModel.toEntity(),
    );
  }
}