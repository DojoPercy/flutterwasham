// lib/models/payment_review_models.dart

import 'package:flutter/foundation.dart'; // For @required
// Assuming paymentStatus and PaymentStatus enum are available from order_models.dart

// --- DTOs for Requests ---

class RecordCashPaymentDto {
  final double amount;

  RecordCashPaymentDto({required this.amount});

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
    };
  }
}

class ReviewDto {
  final String orderId;
  final int rating;
  final String comment;

  ReviewDto({
    required this.orderId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}

// You might also need a model for Paystack's initialization response
class PaystackInitializationResponse {
  final bool status;
  final String message;
  final PaystackData data;

  PaystackInitializationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PaystackInitializationResponse.fromJson(Map<String, dynamic> json) {
    return PaystackInitializationResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: PaystackData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class PaystackData {
  final String authorizationUrl;
  final String accessCode;
  final String reference;

  PaystackData({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  factory PaystackData.fromJson(Map<String, dynamic> json) {
    return PaystackData(
      authorizationUrl: json['authorization_url'] as String,
      accessCode: json['access_code'] as String,
      reference: json['reference'] as String,
    );
  }
}
