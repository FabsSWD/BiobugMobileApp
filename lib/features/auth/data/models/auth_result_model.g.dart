// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResultModel _$AuthResultModelFromJson(Map<String, dynamic> json) =>
    AuthResultModel(
      accessToken: json['token'] as String,
      expirationTime: (json['tokenExpiration'] as num).toInt(),
      userModel: UserModel.fromJson(json['userData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResultModelToJson(AuthResultModel instance) =>
    <String, dynamic>{
      'token': instance.accessToken,
      'tokenExpiration': instance.expirationTime,
      'userData': instance.userModel,
    };
