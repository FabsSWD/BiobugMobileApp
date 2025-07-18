import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/login_params.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String username;
  final String password;

  const LoginRequestModel({
    required this.username,
    required this.password,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);

  factory LoginRequestModel.fromEntity(LoginParams params) {
    return LoginRequestModel(
      username: params.username,
      password: params.password,
    );
  }
}