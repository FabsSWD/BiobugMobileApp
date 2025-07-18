// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'auth_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResultModel _$AuthResultModelFromJson(Map<String, dynamic> json) =>
    AuthResultModel(
      accessToken: json['token'] as String,
      refreshTokenValue: json['tokenRefresh'] as String?,
      expirationTime: (json['tokenExpiration'] as num).toInt(),
      userModel: json['userData'] == null
          ? null
          : UserModel.fromJson(json['userData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResultModelToJson(AuthResultModel instance) =>
    <String, dynamic>{
      'token': instance.accessToken,
      'tokenRefresh': instance.refreshTokenValue,
      'tokenExpiration': instance.expirationTime,
      'userData': instance.userModel,
    };
