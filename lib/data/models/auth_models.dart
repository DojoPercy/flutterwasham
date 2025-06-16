// lib/models/auth_models.dart

import 'package:flutter/foundation.dart';

// --- Request DTOs ---

class LoginDto {
  final String email;
  final String password;

  LoginDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? phoneNumber;

  RegisterDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (gender != null) 'gender': gender,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

class LoginFirebaseDto {
  final String email;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? phoneNumber;

  LoginFirebaseDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.phoneNumber,
  });

  // CORRECTED: toJson sends 'email', not 'idToken'
  Map<String, dynamic> toJson() {
    return {
      'email': email, // This should be the user's email, as expected by backend
      'firstName': firstName,
      'lastName': lastName,
      if (gender != null) 'gender': gender,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

// --- Response Models ---

class AuthResponse {
  final String accessToken;
  final bool? existingUser; // Optional for firebase login response

  AuthResponse({
    required this.accessToken,
    this.existingUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      existingUser:
          json['existingUser'] as bool?, // Can be null if not provided
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'accessToken': accessToken};
    if (existingUser != null) {
      data['existingUser'] = existingUser;
    }
    return data;
  }
}

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? gender;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.gender,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      if (gender != null) 'gender': gender,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UserExistenceResponse {
  final bool exists;

  UserExistenceResponse({required this.exists});

  factory UserExistenceResponse.fromJson(Map<String, dynamic> json) {
    return UserExistenceResponse(
      exists: json['exists'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {'exists': exists};
}
