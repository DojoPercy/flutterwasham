// lib/repositories/review_repository.dart

import 'dart:convert';
import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/httputils.dart';
import 'package:WashAm/data/models/order.dart';
import 'package:WashAm/data/models/payment_review.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewRepository {
  final String baseUrl;
  ReviewRepository(
      {this.baseUrl = 'https://washamlaundryapi.onrender.com/review'});

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

  // ... (rest of ReviewRepository methods remain the same)
  /// POST /review/submit
  Future<Review> submitReview(ReviewDto dto) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/submit',
        dto,
      );
      final data = _handleResponse(response);
      return Review.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to submit review for order ${dto.orderId} due to an unknown error: $e');
    }
  }

  /// GET /review/get/:orderId
  Future<Review> getReview(String orderId) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/get/$orderId',
      );
      final data = _handleResponse(response);
      return Review.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to get review for order $orderId due to an unknown error: $e');
    }
  }
}
