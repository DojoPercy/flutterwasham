// lib/models/address_models.dart

import 'package:flutter/foundation.dart';

// --- Request DTOs ---

class CreateAddressDto {
  final String placeId;
  final String label;
  final String? description;

  CreateAddressDto({
    required this.placeId,
    required this.label,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'label': label,
      if (description != null) 'description': description,
    };
  }
}

// You might need an UpdateAddressDto if it differs from CreateAddressDto
// For now, assuming it's similar or a partial update can use CreateAddressDto
// If update can only modify label and description:
class UpdateAddressDto {
  final String? label;
  final String? description;
  final bool? isPrimary; // Assuming this could be updated

  UpdateAddressDto({
    this.label,
    this.description,
    this.isPrimary,
  });

  Map<String, dynamic> toJson() {
    return {
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (isPrimary != null) 'isPrimary': isPrimary,
    };
  }
}

// --- Response Model (Dart representation of your Prisma Address model) ---

class Address {
  final String id;
  final String userId;
  final String label;
  final String? description;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? placeId;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    this.description,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.placeId,
    this.latitude,
    this.longitude,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['userId'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      placeId: json['placeId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPrimary: json['isPrimary'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      if (description != null) 'description': description,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postalCode': postalCode,
      if (country != null) 'country': country,
      if (placeId != null) 'placeId': placeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Optional: Add a toLatLng getter if you use Maps_flutter
}
