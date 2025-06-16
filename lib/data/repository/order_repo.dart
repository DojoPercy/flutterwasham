// lib/repositories/order_repository.dart

import 'dart:convert';
import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/httputils.dart';
import 'package:WashAm/data/models/order.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  final String baseUrl;
  OrderRepository({
    this.baseUrl = 'https://washamlaundryapi.onrender.com/orders',
  });

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        // Use FetchDataException for parsing errors, as it's an error during communication/data handling
        throw FetchDataException('Failed to parse response body: $e');
      }
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw BadRequestException(errorData['message'] ?? 'Bad Request');
    } else if (response.statusCode == 404) {
      final errorData = json.decode(response.body);
    } else if (response.statusCode == 401) {
      final errorData = json.decode(response.body); // Parse to get message
      throw UnauthorizedException(errorData['message'] ?? 'Unauthorized');
    } else {
      // For any other non-2xx, non-400, non-401, non-404 status codes
      final errorData = json.decode(response.body);
      throw ApiBusinessException(
        errorData['message'] ??
            'An unexpected error occurred with status ${response.statusCode}',
      );
    }
  }

  // ... (rest of OrderRepository methods remain the same)
  /// POST /orders
  Future<Order> createOrder(CreateOrderDto dto) async {
    try {
      final response = await HttpUtils.postRequest(baseUrl, dto);
      final data = _handleResponse(response);
      return Order.fromJson(data);
    } on AppException {
      // Catching base AppException allows re-throwing specific types
      rethrow;
    } catch (e) {
      // This catch is for unexpected non-AppException errors
      throw ApiBusinessException(
          'Failed to create order due to an unknown error: $e');
    }
  }

  /// GET /orders
  Future<List<Order>> findMyOrders() async {
    try {
      final response = await HttpUtils.getRequest(baseUrl);
      final List<dynamic> data = _handleResponse(response);
      return data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to fetch my orders due to an unknown error: $e');
    }
  }

  /// GET /orders/:id
  Future<Order> findOneOrder(String orderId) async {
    try {
      final response = await HttpUtils.getRequest(
        baseUrl,
        pathParams: orderId,
      );
      final data = _handleResponse(response);
      return Order.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to fetch order $orderId due to an unknown error: $e');
    }
  }

  /// PUT /orders
  Future<Order> updateOrderFunc(UpdateOrderDto dto) async {
    try {
      final response = await HttpUtils.putRequest(baseUrl, dto);
      final data = _handleResponse(response);
      return Order.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to update order status due to an unknown error: $e');
    }
  }

  /// PUT /orders/:id/cancel
  Future<Order> cancelOrder(String orderId) async {
    try {
      final response = await HttpUtils.putRequest(
        '$baseUrl/$orderId/cancel',
        {},
      );
      final data = _handleResponse(response);
      return Order.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to cancel order due to an unknown error: $e');
    }
  }

  /// PUT /orders/:id/reschedule
  Future<Order> rescheduleOrder(String orderId, RescheduleOrderDto dto) async {
    try {
      final response = await HttpUtils.putRequest(
        '$baseUrl/$orderId/reschedule',
        dto,
      );
      final data = _handleResponse(response);
      return Order.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to reschedule order due to an unknown error: $e');
    }
  }

  /// GET /orders/:id/status
  Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/$orderId/status',
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to get order status due to an unknown error: $e');
    }
  }

  /// GET /orders/:id/history
  Future<List<OrderHistoryEntry>> getOrderHistory(String orderId) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/$orderId/history',
      );
      final List<dynamic> data = _handleResponse(response);
      return data
          .map((e) => OrderHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to get order history due to an unknown error: $e');
    }
  }

  /// POST /orders/estimate
  Future<Map<String, dynamic>> estimateOrder(EstimateOrderDto dto) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/estimate',
        dto,
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to estimate order due to an unknown error: $e');
    }
  }
}
