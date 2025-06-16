import 'package:WashAm/configuration/app_logger.dart';
import 'package:WashAm/configuration/constants.dart';
import 'package:WashAm/configuration/local_storage.dart';
import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/models/auth_models.dart';
import 'package:WashAm/data/repository/auth_repository.dart';
import 'package:WashAm/presentation/common_blocs/auth/auth_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  static final _log = AppLogger.getLogger("AuthBloc");

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<SignInWithGoogleRequested>(_onGoogleSignIn);
    on<CompleteFirebaseRegistration>(_onCreateNewUser);
    on<LoadUserProfileFromStorage>(_onLoadUserProfileFromStorage);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UserProfileUpdated>(_onUserProfileUpdated);
  }

  Future<void> _onGoogleSignIn(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userExists = await authRepository.signInWithGoogleAndBackendLogin();
      if (userExists) {
      } else {
        emit(AuthNewUser());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCreateNewUser(
    CompleteFirebaseRegistration event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final success =
          await authRepository.authenticateUserWithFirebaseBackend(event.data);
      if (success.accessToken != null) {
        final userProfile = await authRepository.getMe();
        await AppLocalStorage().save(StorageKeysData.userProfile, userProfile);
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Authentication failed"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onUserProfileUpdated(
      UserProfileUpdated event, Emitter<AuthState> emit) {
    emit(AuthSuccessWithProfile(userProfile: event.userProfile));
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userProfile = await authRepository.getMe();
      await AppLocalStorage().save(StorageKeysData.userProfile, userProfile);
      emit(AuthSuccess());
    } on AppException catch (e) {
      _log.error('AuthBloc - Fetch User Profile Failed: ${e}');
      emit(AuthFailure(e.toString()));
    } catch (e) {
      _log.error('AuthBloc - Unexpected Fetch User Profile Error: $e');
      emit(AuthFailure(
          'An unexpected error occurred while fetching user profile.'));
    }
  }

  Future<void> _onLoadUserProfileFromStorage(
    LoadUserProfileFromStorage event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final dynamic storedData =
          await AppLocalStorage().read(StorageKeysData.userProfile);

      // Check if storedData is not null and is of the expected type (Map<String, dynamic>)
      if (storedData != null && storedData is Map<String, dynamic>) {
        final userProfile = UserProfile.fromJson(storedData); // Cast for safety

        if (userProfile != null) {
          // This check might be redundant if fromJson always returns a valid object or throws
          emit(AuthSuccessWithProfile(userProfile: userProfile));
        } else {
          // This case might be hit if fromJson returns null, which is less common for fromJson methods
          emit(AuthFailure(
              'User profile could not be deserialized from local storage.'));
        }
      } else {
        // If storedData is null or not a Map<String, dynamic>, it means the profile isn't found or is malformed.
        final userProfile = await authRepository.getMe();

        await AppLocalStorage()
            .save(StorageKeysData.userProfile, userProfile.toJson());
        emit(AuthSuccessWithProfile(userProfile: userProfile));
      }
    } catch (e) {
      _log.error('AuthBloc - Load User Profile From Storage Error: $e');
      emit(AuthFailure('Failed to load user profile from local storage.'));
    }
  }
}
