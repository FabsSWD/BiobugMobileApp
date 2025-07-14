import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/register_params.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final int idType;
  final int identification;
  final String fullName;
  final String email;
  final String password;

  const RegisterRequestModel({
    required this.idType,
    required this.identification,
    required this.fullName,
    required this.email,
    required this.password,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);

  factory RegisterRequestModel.fromEntity(RegisterParams params) {
    return RegisterRequestModel(
      idType: params.idType,
      identification: params.identification,
      fullName: params.fullName,
      email: params.email,
      password: params.password,
    );
  }
}