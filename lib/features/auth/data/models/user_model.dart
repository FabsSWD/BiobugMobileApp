import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.idType,
    required super.identification,
    required super.fullName,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      idType: user.idType,
      identification: user.identification,
      fullName: user.fullName,
      email: user.email,
    );
  }

  User toEntity() {
    return User(
      userId: userId,
      idType: idType,
      identification: identification,
      fullName: fullName,
      email: email,
    );
  }
}