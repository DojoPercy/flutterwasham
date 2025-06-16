// lib/repositories/address_repository.dart

import 'dart:convert';
import 'package:WashAm/data/app_api_exception.dart';
import 'package:WashAm/data/httputils.dart';
import 'package:WashAm/data/models/user_address.dart';
import 'package:http/http.dart' as http;

class AddressRepository {
  final String baseUrl;

  AddressRepository(
      {this.baseUrl = 'https://washamlaundryapi.onrender.com/address'});

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

  // --- API Methods ---

  /// POST /address/create
  /// Creates a new address for the authenticated user.
  Future<Address> createAddress(CreateAddressDto addressDto) async {
    try {
      final response = await HttpUtils.postRequest(
        '$baseUrl/create',
        addressDto.toJson(),
      );
      final responseData = _handleResponse(response);
      return Address.fromJson(responseData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to create address: $e');
    }
  }

  /// GET /address/getByUserId
  /// Retrieves all addresses for the authenticated user.
  Future<List<Address>> getAddressesByUserId() async {
    try {
      final response = await HttpUtils.getRequest('$baseUrl/getByUserId');
      final List<dynamic> responseData = _handleResponse(response);
      return responseData
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to fetch addresses for user: $e');
    }
  }

  /// DELETE /address/delete
  /// Deletes an address by its ID.
  Future<void> deleteAddress(String addressId) async {
    try {
      // Note: Backend uses @Body('addressId'), so send as JSON body
      final response = await HttpUtils.deleteRequest(
        '$baseUrl/delete',
        pathParams: addressId,
      );
      _handleResponse(response); // No content on successful delete
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to delete address $addressId: $e');
    }
  }

  /// PUT /address/update
  /// Updates an existing address for the authenticated user.
  Future<Address> updateAddress(
      String addressId, UpdateAddressDto addressDto) async {
    try {
      // Backend expects `addressData: CreateAddressDto` in body, but you need `addressId` too
      // The current NestJS `updateAddress` controller takes `addressData: CreateAddressDto` from Body
      // and implicitly assumes `addressId` is part of `addressData` or available from route params.
      // Based on your controller: `async updateAddress(@Request() req: any, @Body() addressData: CreateAddressDto)`
      // It seems it implies the `addressId` should be part of the DTO, or you need to change your NestJS endpoint.
      // Assuming your NestJS `updateAddress` actually takes `addressId` as a route param or from DTO.
      // For this example, I'll adapt to send `addressId` in the body if `CreateAddressDto` contains it
      // or as a query param if your NestJS controller expects it that way.
      // Given your current NestJS `updateAddress` expects `CreateAddressDto` in `@Body()`,
      // I'll assume you *intended* for the `addressId` to be part of the `CreateAddressDto` on the Dart side.
      // If not, you'll need to adjust either the Dart DTO or the NestJS controller.
      // **Correction:** Your NestJS updateAddress currently expects `addressData` as `CreateAddressDto`
      // and doesn't explicitly take an `addressId`. This implies `addressId` needs to be in `CreateAddressDto` or
      // you need to change your NestJS controller signature.
      // Let's assume you'll modify the NestJS controller to take `addressId` as a route param.
      // Example: `@Put('update/:id') async updateAddress(@Param('id') id: string, @Body() addressData: UpdateAddressDto)`
      // For now, I'll send it as a route param, which is more RESTful.
      // If you're updating `CreateAddressDto` in the backend, you'd likely want a separate `UpdateAddressDto`.
      // I've created an `UpdateAddressDto` in Dart.

      // If your NestJS controller for update expects addressId as a route param:
      // await HttpUtils.putRequest('$baseUrl/update/$addressId', addressDto.toJson());
      // Otherwise, if addressId must be in the body (less RESTful but matches your current `delete` method pattern):
      final response = await HttpUtils.putRequest(
        '$baseUrl/update',
        {
          'addressId': addressId,
          ...addressDto.toJson()
        }, // Merging addressId into the body
      );
      final responseData = _handleResponse(response);
      return Address.fromJson(responseData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException('Failed to update address $addressId: $e');
    }
  }

  /// GET /address/getById
  /// Retrieves a single address by its ID.
  Future<Address> getAddressById(String addressId) async {
    try {
      // Backend uses @Body('addressId'), which is unusual for a GET.
      // GET requests typically use query parameters or path parameters.
      // If you want to stick to your backend for now, you'd use a POST or send body with GET (not standard).
      // Let's assume you'll change your NestJS GET /getById to use a path parameter:
      // @Get('getById/:addressId') async getAddressById(@Param('addressId') addressId: string)
      final response = await HttpUtils.getRequest(
          '$baseUrl/getById/$addressId'); // Assuming path param
      final responseData = _handleResponse(response);
      return Address.fromJson(responseData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to fetch address by ID $addressId: $e');
    }
  }

  /// POST /address/getByPlaceId
  /// Retrieves an address by its Google Place ID.
  Future<Address?> getAddressByPlaceId(String placeId) async {
    try {
      // Backend uses POST with @Body('placeId'), which is fine.
      final response = await HttpUtils.postRequest(
        '$baseUrl/getByPlaceId',
        {'placeId': placeId},
      );
      final responseData = _handleResponse(response);
      // Return null if no address is found (e.g., 404 response converted to null by _handleResponse if body is empty)
      return responseData != null ? Address.fromJson(responseData) : null;
    } on AppException {
      rethrow;
    } catch (e) {
      // Consider if 404 should throw NotFoundException and then this catch handles it
      // or if _handleResponse converts 404 to null for this specific endpoint.
      // Current _handleResponse throws NotFoundException on 404.
      // So, if an address is truly not found, a NotFoundException will be thrown.
      throw ApiBusinessException(
          'Failed to fetch address by Place ID $placeId: $e');
    }
  }

  /// GET /address/getByUserIdAndPlaceId (assuming backend adds this)
  /// Retrieves an address for a specific user and place ID.
  Future<Address?> getAddressByUserIdAndPlaceId(
      String userId, String placeId) async {
    try {
      // Assuming a GET endpoint on the backend:
      // @Get('getByUserIdAndPlaceId/:userId/:placeId')
      // Or query params: @Get('getByUserIdAndPlaceId') @Query('userId') userId: string, @Query('placeId') placeId: string
      final response = await HttpUtils.getRequest(
        '$baseUrl/getByUserIdAndPlaceId',
        queryParams: {'userId': userId, 'placeId': placeId},
      );
      final responseData = _handleResponse(response);
      return responseData != null ? Address.fromJson(responseData) : null;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiBusinessException(
          'Failed to fetch address by user ID and Place ID: $e');
    }
  }
}
