// lib/features/listing/data/repositories/listing_repository.dart
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/listing_model.dart';
import '../models/property_type_model.dart';

class ListingRepository {
  final Dio _dio;

  ListingRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ─── Property Types ──────────────────────────────────────────────────────────

  Future<List<PropertyTypeModel>> getPropertyTypes({int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiConstants.propertyTypesPath,
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => PropertyTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<List<ListingModel>> getListings() async {
    try {
      final response = await _dio.get('${ApiConstants.listingsPath}/');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  // ─── Listings ─────────────────────────────────────────────────────────────

  Future<ListingModel> createDraft({
    required String propertyTypeId,
    required SpaceType spaceType,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.listingsPath}/',
        data: {
          'property_type_id': propertyTypeId,
          'space_type': spaceType.value,
        },
      );
      return ListingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
  

  Future<ListingModel> updateListing({
    required String id,
    String? propertyTypeId,
    SpaceType? spaceType,
    double? latitude,
    double? longitude,
    String? addressLine1,
    String? city,
    String? postalCode,
    int? maxGuests,
    int? bedrooms,
    double? bathrooms,
    int? propertySize,
    String? title,
    String? description,
    double? basePrice,
    BookingType? bookingType,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (propertyTypeId != null) body['property_type_id'] = propertyTypeId;
      if (spaceType != null) body['space_type'] = spaceType.value;

      // Lat/lng MUST be sent together per API contract
      if (latitude != null && longitude != null) {
        body['latitude'] = latitude;
        body['longitude'] = longitude;
      } else if (latitude != null || longitude != null) {
        throw const ServerException(
          message: 'Latitude dan longitude harus diisi bersama-sama.',
          statusCode: 422,
        );
      }

      if (addressLine1 != null) body['address_line_1'] = addressLine1;
      if (city != null) body['city'] = city;
      if (postalCode != null) body['postal_code'] = postalCode;
      if (maxGuests != null) body['max_guests'] = maxGuests;
      if (bedrooms != null) body['bedrooms'] = bedrooms;
      if (bathrooms != null) body['bathrooms'] = bathrooms;
      if (propertySize != null) body['property_size'] = propertySize;
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (basePrice != null) body['base_price'] = basePrice;
      if (bookingType != null) body['booking_type'] = bookingType.value;

      final response = await _dio.patch(
        '${ApiConstants.listingsPath}/$id',
        data: body,
      );
      return ListingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<ListingModel> publishListing(String id) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.listingsPath}/$id/publish',
      );
      return ListingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  // ─── Error Handling ──────────────────────────────────────────────────────────

  AppException _handleDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        if (statusCode == 422) {
          String msg = 'Data tidak valid.';
          if (data is Map && data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is List && detail.isNotEmpty) {
              // Pydantic v2 returns a list of {loc, msg, type} objects
              final messages = detail
                  .whereType<Map>()
                  .map((err) {
                    final loc = (err['loc'] as List?)?.skip(1).join(' → ') ?? '';
                    final errMsg = err['msg']?.toString() ?? '';
                    return loc.isNotEmpty ? '$loc: $errMsg' : errMsg;
                  })
                  .where((s) => s.isNotEmpty)
                  .toList();
              if (messages.isNotEmpty) {
                msg = messages.join('\n');
              }
            } else if (detail is String && detail.isNotEmpty) {
              msg = detail;
            }
          }
          return ValidationException(message: msg, detail: data);
        }
        return ServerException(
          message: 'Server error ($statusCode).',
          statusCode: statusCode,
          rawData: data,
        );
      default:
        return const UnknownException();
    }
  }
}
