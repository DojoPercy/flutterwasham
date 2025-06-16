// lib/repositories/payment_repository.dart

import 'dart:convert';
import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/httputils.dart';
import 'package:WashAm/data/models/order.dart';
import 'package:WashAm/data/models/payment_review.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  final String baseUrl;
  PaymentRepository({this.baseUrl = 'https://washamlaundryapi.onrender.com'});

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

  // ... (rest of PaymentRepository methods remain the same)
  /// POST /orders/:orderId/payment
  Future<PaystackInitializationResponse> initiatePayment(String orderId) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/orders/$orderId/payment',
        {},
      );
      final data = _handleResponse(response);
      return PaystackInitializationResponse.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to initiate payment for order $orderId due to an unknown error: $e');
    }
  }

  /// GET /orders/:orderId/payment
  Future<Payment> getPaymentDetails(String orderId) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/orders/$orderId/payment',
      );
      final data = _handleResponse(response);
      return Payment.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to get payment details for order $orderId due to an unknown error: $e');
    }
  }

  /// POST /orders/:orderId/payment/cash
  Future<Map<String, dynamic>> recordCashPayment(
      String orderId, double amount) async {
    try {
      final recordCashDto = RecordCashPaymentDto(amount: amount);
      final response = await HttpUtils.postRequest(
        '$baseUrl/orders/$orderId/payment/cash',
        recordCashDto,
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to record cash payment for order $orderId due to an unknown error: $e');
    }
  }
}
