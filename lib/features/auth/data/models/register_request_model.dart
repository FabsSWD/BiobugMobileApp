import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/register_params.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String idType;
  final String identification;
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
      idType: params.idType.toString().padLeft(2, '0'), // "01" para cédula física
      identification: params.identification.toString(),
      fullName: params.fullName,
      email: params.email,
      password: params.password,
    );
  }
}