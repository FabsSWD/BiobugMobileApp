// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
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
