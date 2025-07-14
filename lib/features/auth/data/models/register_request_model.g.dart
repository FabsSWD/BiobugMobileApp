// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => RegisterRequestModel(
  idType: (json['idType'] as num).toInt(),
  identification: (json['identification'] as num).toInt(),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  RegisterRequestModel instance,
) => <String, dynamic>{
  'idType': instance.idType,
  'identification': instance.identification,
  'fullName': instance.fullName,
  'email': instance.email,
  'password': instance.password,
};
