// lib/repositories/auth_repository.dart

import 'dart:convert';
import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/models/auth_models.dart';
import 'package:WashAm/data/models/auth_response.dart';
import 'package:WashAm/data/models/login_firebase.dart';
import 'package:WashAm/data/models/user_exist_response.dart';
import 'package:http/http.dart' as http; // Alias as http for clarity

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:WashAm/configuration/app_logger.dart';
import 'package:WashAm/configuration/constants.dart'; // For StorageKeysData
import 'package:WashAm/configuration/local_storage.dart';
import 'package:WashAm/data/httputils.dart'; // Correct path to your HttpUtils

class AuthRepository {
  static final _log = AppLogger.getLogger("AuthRepository");
  final String baseUrl;

  AuthRepository({this.baseUrl = 'https://washamlaundryapi.onrender.com'});

  // Helper method to handle HTTP responses (centralized error handling)
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        throw FetchDataException('Failed to parse response body: $e');
      }
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw BadRequestException(errorData['message'] ?? 'Bad Request');
    } else if (response.statusCode == 404) {
      final errorData = json.decode(response.body);
    } else if (response.statusCode == 401) {
      final errorData = json.decode(response.body);
      throw UnauthorizedException(errorData['message'] ?? 'Unauthorized');
    } else {
      final errorData = json.decode(response.body);
      throw ApiBusinessException(
        errorData['message'] ??
            'An unexpected error occurred with status ${response.statusCode}',
      );
    }
  }

  // --- Core Authentication Methods (from previous example) ---

  /// POST /auth/login
  Future<AuthResponse> login(LoginDto loginDto) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/auth/login',
        loginDto.toJson(), // Use toJson()
      );
      final data = _handleResponse(response);
      final authResponse = AuthResponse.fromJson(data);
      await AppLocalStorage()
          .save(StorageKeys.jwtToken.name, authResponse.accessToken);
      return authResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to login: $e');
    }
  }

  /// POST /auth/register
  Future<UserProfile> register(RegisterDto registerDto) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/auth/register',
        registerDto.toJson(), // Use toJson()
      );
      final data = _handleResponse(response);
      final userProfile = UserProfile.fromJson(data);
      // Assuming register endpoint directly returns user profile, no token here
      return userProfile;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to register: $e');
    }
  }

  /// GET /auth/me
  Future<UserProfile> getMe() async {
    try {
      final response = await HttpUtils.getRequest('$baseUrl/v1/auth/me');
      final data = _handleResponse(response);

      return UserProfile.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to fetch user profile: $e');
    }
  }

  // --- Firebase/Google Sign-In Specific Methods ---

  /// Initiates Google Sign-In, checks user existence on backend, and performs backend Firebase login.
  /// Returns AuthResponse which includes accessToken and existingUser status.
  Future<bool> signInWithGoogleAndBackendLogin() async {
    try {
      _log.info('Started Google Sign-In process.');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw UnauthorizedException('Google Sign-In cancelled by user.');
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      if (googleAuth?.idToken == null) {
        throw UnauthorizedException('Google ID Token not found.');
      }

      // Authenticate with Firebase using Google credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final userEmail = googleUser.email;

      _log.debug(
          'Completed Firebase Sign In. Checking user existence on backend.');

      // 1. Check user existence on your backend
      final userExistenceResponse = await _checkUserExistence(userEmail);
      await AppLocalStorage().save(StorageKeysData.userEmail, userEmail);
      await AppLocalStorage()
          .save(StorageKeysData.isExistingUser, userExistenceResponse.exists);
      if (userExistenceResponse.exists) {
        final UserProfile user = await _getUserByMail(userEmail);
        AppLocalStorage().save(StorageKeysData.userProfile, user);
      }
      _log.debug('Backend Firebase login successful. Access Token stored.');
      return userExistenceResponse.exists;
    } on FirebaseAuthException catch (e) {
      _log.error('Firebase Auth Error: ${e.code} - ${e.message}');
      throw UnauthorizedException(
          'Firebase authentication failed: ${e.message}');
    } on AppException {
      rethrow; // Re-throw custom API exceptions
    } catch (e) {
      _log.error('Error during Google Sign-In and backend login: $e');
      throw ApiBusinessException(
          'An unexpected error occurred during Google sign-in.');
    }
  }

  // Internal helper to check user existence
  Future<UserExistenceResponse> _checkUserExistence(String email) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/v1/users/check-email/$email', // Adjusted path to be correct RESTful
      );
      final data = _handleResponse(response);
      return UserExistenceResponse.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to check user existence: $e');
    }
  }

  // Internal helper to check user existence
  Future<UserProfile> _getUserByMail(String email) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/v1/users/email/$email', // Adjusted path to be correct RESTful
      );
      final data = _handleResponse(response);
      return UserProfile.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to check user existence: $e');
    }
  }

  // Internal helper to authenticate/register user on backend via Firebase details
  Future<AuthResponse> authenticateUserWithFirebaseBackend(
      LoginFirebaseDto data) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/auth/firebase-login',
        data.toJson(),
      );
      final responseData = _handleResponse(response);
      return AuthResponse.fromJson(responseData);
    } on AppException {
      rethrow;
    } catch (e) {
      _log.error('Error in authenticateUserWithFirebaseBackend:', [e]);
      throw ApiBusinessException(
          'Failed to authenticate user with backend via Firebase: $e');
    }
  }

  /// Logs out the user by clearing local storage and Firebase session.
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await AppLocalStorage().clear();
      _log.info('User logged out successfully.');
    } catch (e) {
      _log.error('Error during logout: $e');
      throw ApiBusinessException('Failed to log out: $e');
    }
  }
}
