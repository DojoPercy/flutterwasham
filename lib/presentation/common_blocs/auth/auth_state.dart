import 'package:WashAm/data/models/auth_models.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthNewUser extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccessWithProfile extends AuthState {
  final UserProfile userProfile;

  AuthSuccessWithProfile({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}
