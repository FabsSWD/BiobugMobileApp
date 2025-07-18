import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

part 'auth_result_model.g.dart';

@JsonSerializable()
class AuthResultModel extends AuthResult {
  @JsonKey(name: 'token')
  final String accessToken;
  
  @JsonKey(name: 'tokenRefresh')
  final String? refreshTokenValue;
  
  @JsonKey(name: 'tokenExpiration')
  final int expirationTime;
  
  @JsonKey(name: 'userData')
  final UserModel? userModel;

  const AuthResultModel({
    required this.accessToken,
    this.refreshTokenValue,
    required this.expirationTime,
    this.userModel,
  }) : super(
          token: accessToken,
          refreshToken: refreshTokenValue ?? '',
          tokenExpiration: expirationTime,
          user: userModel,
        );

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 AuthResultModel.fromJson - Input: $json');
      
      // Extraer datos del usuario desde diferentes posibles estructuras
      UserModel? userModel;
      
      // Caso 1: userData está directamente en el JSON
      if (json['userData'] != null) {
        print('📍 Found userData in JSON');
        if (json['userData'] is Map<String, dynamic>) {
          userModel = UserModel.fromJson(json['userData'] as Map<String, dynamic>);
        }
      }
      
      // Caso 2: user está en el JSON (formato alternativo)
      else if (json['user'] != null) {
        print('📍 Found user in JSON');
        if (json['user'] is Map<String, dynamic>) {
          userModel = UserModel.fromJson(json['user'] as Map<String, dynamic>);
        }
      }
      
      // Caso 3: Los datos del usuario están en el nivel raíz
      else if (json['userId'] != null || json['fullName'] != null || json['email'] != null) {
        print('📍 Found user data at root level');
        try {
          userModel = UserModel.fromJson(json);
        } catch (e) {
          print('❌ Error parsing user data from root: $e');
        }
      }
      
      final result = AuthResultModel(
        accessToken: json['token'] as String,
        refreshTokenValue: json['tokenRefresh'] as String?,
        expirationTime: (json['tokenExpiration'] as num).toInt(),
        userModel: userModel,
      );
      
      print('✅ AuthResultModel created successfully');
      print('   - Token: ${result.accessToken.substring(0, 20)}...');
      print('   - User: ${result.userModel?.fullName ?? 'null'}');
      
      return result;
      
    } catch (e, stackTrace) {
      print('❌ Error in AuthResultModel.fromJson: $e');
      print('📍 StackTrace: $stackTrace');
      
      // Intentar crear un modelo básico sin datos de usuario
      try {
        return AuthResultModel(
          accessToken: json['token'] as String,
          refreshTokenValue: json['tokenRefresh'] as String?,
          expirationTime: (json['tokenExpiration'] as num).toInt(),
          userModel: null,
        );
      } catch (e2) {
        print('❌ Failed to create basic AuthResultModel: $e2');
        rethrow;
      }
    }
  }

  Map<String, dynamic> toJson() => _$AuthResultModelToJson(this);

  AuthResult toEntity() {
    return AuthResult(
      token: accessToken,
      refreshToken: refreshTokenValue ?? '',
      tokenExpiration: expirationTime,
      user: userModel?.toEntity(),
    );
  }
}