// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: json['userId'] as String,
  idType: (json['idType'] as num).toInt(),
  identification: (json['identification'] as num).toInt(),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'userId': instance.userId,
  'idType': instance.idType,
  'identification': instance.identification,
  'fullName': instance.fullName,
  'email': instance.email,
};
