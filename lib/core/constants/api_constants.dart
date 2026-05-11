// lib/core/constants/api_constants.dart
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://propertylisting-oyjm.onrender.com';
  static const String apiVersion = '/api/v1';
  static const String listingsPath = '$apiVersion/listings';
  static const String propertyTypesPath = '$apiVersion/property-types';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Local storage keys
  static const String keyListingId = 'listing_id';
  static const String keyCurrentStep = 'current_step';
  static const String keySpaceType = 'space_type';
  static const String keyPropertyTypeId = 'property_type_id';
}
