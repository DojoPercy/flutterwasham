import 'package:WashAm/data/models/auth_models.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInWithGoogleRequested extends AuthEvent {}

// This event is for completing the registration for a new Firebase user
// who needs to provide additional details.
class CompleteFirebaseRegistration extends AuthEvent {
  final LoginFirebaseDto data;

  CompleteFirebaseRegistration(this.data);

  @override
  List<Object?> get props => [data];
}

// Add standard login event for email/password
class LoginRequested extends AuthEvent {
  final LoginDto loginDto;

  LoginRequested(this.loginDto);

  @override
  List<Object?> get props => [loginDto];
}

// Add standard registration event for email/password
class RegisterRequested extends AuthEvent {
  final RegisterDto registerDto;

  RegisterRequested(this.registerDto);

  @override
  List<Object?> get props => [registerDto];
}

// Event to fetch user profile (e.g., after app starts, or on profile screen)
class FetchUserProfile extends AuthEvent {}

// Event for user logout
class LogoutRequested extends AuthEvent {}

class LoadUserProfileFromStorage extends AuthEvent {}

class UserProfileUpdated extends AuthEvent {
  final UserProfile userProfile;

  UserProfileUpdated(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}
