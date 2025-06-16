// lib/repositories/wallet_repository.dart

// Remove direct http import if you rely solely on HttpUtils
// import 'package:http/http.dart' as http;
import 'dart:convert'; // Still needed for json.decode

import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/httputils.dart';
import 'package:WashAm/data/models/wallet.dart';
import 'package:http/http.dart' as http; // Import your models

// Custom Exception classes - only define these if they're not already in app_api_exception.dart
// Assuming FetchDataException, UnauthorizedException are defined in app_api_exception.dart
// If BadRequestApiException or NotFoundApiException are not in app_api_exception.dart,
// you might want to define them there, or map HttpUtils errors to these.
// For now, I'll map them to the existing ones like FetchDataException.
// If your backend throws specific error codes/messages, you'd extend AppApiException
// like you have for UnauthorizedException.
class WalletApiException implements Exception {
  final String message;
  final int? statusCode;
  WalletApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'WalletApiException ($statusCode): $message';
    }
    return 'WalletApiException: $message';
  }
}
// You can define more specific exceptions if needed, similar to your backend, e.g.:
// class InsufficientFundsException extends WalletApiException {
//   InsufficientFundsException(String message) : super(message, statusCode: 400);
// }

class WalletRepository {
  final String baseUrl; // e.g., 'https://washamlaundryapi.onrender.com/wallet'

  WalletRepository({
    this.baseUrl =
        'https://washamlaundryapi.onrender.com/wallet', // Set default base URL
  });

  // Helper method to handle HTTP responses from HttpUtils
  // HttpUtils already handles 401, timeout, and socket exceptions.
  // We'll handle other application-specific errors here.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        return null; // No Content
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        throw WalletApiException('Failed to parse response body: $e');
      }
    } else if (response.statusCode == 400) {
      // Assuming your backend sends a 'message' field for 400 errors
      final errorData = json.decode(response.body);
      throw FetchDataException(errorData['message'] ?? 'Bad Request');
    } else if (response.statusCode == 404) {
      final errorData = json.decode(response.body);
      throw FetchDataException(errorData['message'] ?? 'Resource Not Found');
    } else {
      // General error for other status codes not explicitly handled by HttpUtils
      final errorData = json.decode(response.body);
      throw WalletApiException(
        errorData['message'] ?? 'An unexpected error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  // --- API Methods ---

  /// Creates a new wallet for a user.
  /// POST /wallet
  Future<Wallet> createWallet(CreateWalletDto dto) async {
    try {
      final response = await HttpUtils.postRequest(
        baseUrl,
        dto, // HttpUtils uses JsonMapper.serialize for the body
      );
      final data = _handleResponse(response);
      return Wallet.fromJson(data);
    } on AppException {
      // Catch specific exceptions from HttpUtils
      rethrow; // Re-throw them
    } catch (e) {
      throw WalletApiException('Failed to create wallet: $e');
    }
  }

  /// Retrieves a user's wallet and its transactions.
  /// GET /wallet/:userId
  Future<Wallet> getWalletByUserId(String userId) async {
    try {
      final response = await HttpUtils.getRequest(
        baseUrl,
        pathParams: userId,
      );
      final data = _handleResponse(response);
      return Wallet.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw WalletApiException('Failed to fetch wallet: $e');
    }
  }

  /// Adds a transaction (credit or debit) to a user's wallet.
  /// POST /wallet/:userId/transaction
  Future<Map<String, dynamic>> addTransaction(
    String userId,
    WalletTransactionDto dto,
  ) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/$userId/transaction',
        dto,
      );
      final data = _handleResponse(response);
      // Assuming your backend returns { wallet: Wallet, transaction: WalletTransaction }
      return {
        'wallet': Wallet.fromJson(data['wallet']),
        'transaction': WalletTransaction.fromJson(data['transaction']),
      };
    } on AppException {
      rethrow;
    } catch (e) {
      throw WalletApiException('Failed to add transaction: $e');
    }
  }

  /// Retrieves all transactions for a user's wallet.
  /// GET /wallet/:userId/transactions
  Future<List<WalletTransaction>> getTransactions(String userId) async {
    try {
      final response = await HttpUtils.getRequest(
        '$baseUrl/$userId/transactions',
      );
      final List<dynamic> data = _handleResponse(response);
      return data
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw WalletApiException('Failed to fetch transactions: $e');
    }
  }

  /// Deletes a user's wallet and all associated transactions.
  /// DELETE /wallet/:userId
  Future<void> deleteWallet(String userId) async {
    try {
      final response = await HttpUtils.deleteRequest(
        baseUrl,
        pathParams: userId,
      );
      _handleResponse(response); // No content expected, or just a message
    } on AppException {
      rethrow;
    } catch (e) {
      throw WalletApiException('Failed to delete wallet: $e');
    }
  }
}
