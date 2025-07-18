import 'package:equatable/equatable.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final LoginParams params;

  const AuthLoginEvent(this.params);

  @override
  List<Object> get props => [params];
}

class AuthRegisterEvent extends AuthEvent {
  final RegisterParams params;

  const AuthRegisterEvent(this.params);

  @override
  List<Object> get props => [params];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthRefreshTokenEvent extends AuthEvent {}