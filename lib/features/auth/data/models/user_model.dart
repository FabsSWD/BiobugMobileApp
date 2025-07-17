import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  const UserModel({
    required super.userId,
    required super.idType,
    required super.identification,
    required super.fullName,
    required super.email,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle idType conversion from string to int
    int idTypeInt;
    final idTypeValue = json['idType'];
    if (idTypeValue is String) {
      idTypeInt = int.parse(idTypeValue);
    } else {
      idTypeInt = idTypeValue as int;
    }

    // Handle identification conversion from string to int
    int identificationInt;
    final identificationValue = json['identification'];
    if (identificationValue is String) {
      identificationInt = int.parse(identificationValue);
    } else {
      identificationInt = identificationValue as int;
    }

    return UserModel(
      userId: json['userId'] as String,
      idType: idTypeInt,
      identification: identificationInt,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

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