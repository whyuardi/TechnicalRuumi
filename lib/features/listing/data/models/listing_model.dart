// lib/features/listing/data/models/listing_model.dart

enum SpaceType {
  entirePlace('ENTIRE_PLACE', 'Entire Place'),
  privateRoom('PRIVATE_ROOM', 'Private Room'),
  sharedRoom('SHARED_ROOM', 'Shared Room');

  final String value;
  final String label;
  const SpaceType(this.value, this.label);

  static SpaceType fromValue(String value) {
    return SpaceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SpaceType.entirePlace,
    );
  }
}

enum BookingType {
  instant('INSTANT', 'Instant Book'),
  request('REQUEST', 'Approve Manually');

  final String value;
  final String label;
  const BookingType(this.value, this.label);

  static BookingType fromValue(String value) {
    return BookingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingType.instant,
    );
  }
}

enum ListingStatus {
  draft('DRAFT'),
  published('PUBLISHED'),
  archived('ARCHIVED');

  final String value;
  const ListingStatus(this.value);

  static ListingStatus fromValue(String value) {
    return ListingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ListingStatus.draft,
    );
  }
}

class ListingModel {
  final String id;
  final int hostId;
  final ListingStatus status;
  final String? propertyTypeId;
  final SpaceType? spaceType;
  final String? latitude;
  final String? longitude;
  final String? addressLine1;
  final String? city;
  final String? postalCode;
  final int? maxGuests;
  final int? bedrooms;
  final String? bathrooms;
  final int? propertySize;
  final String? title;
  final String? description;
  final String? basePrice;
  final BookingType? bookingType;

  const ListingModel({
    required this.id,
    required this.hostId,
    required this.status,
    this.propertyTypeId,
    this.spaceType,
    this.latitude,
    this.longitude,
    this.addressLine1,
    this.city,
    this.postalCode,
    this.maxGuests,
    this.bedrooms,
    this.bathrooms,
    this.propertySize,
    this.title,
    this.description,
    this.basePrice,
    this.bookingType,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      hostId: json['host_id'] as int,
      status: ListingStatus.fromValue(json['status'] as String),
      propertyTypeId: json['property_type_id'] as String?,
      spaceType: json['space_type'] != null
          ? SpaceType.fromValue(json['space_type'] as String)
          : null,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      addressLine1: json['address_line_1'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      maxGuests: json['max_guests'] as int?,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms']?.toString(),
      propertySize: json['property_size'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      basePrice: json['base_price']?.toString(),
      bookingType: json['booking_type'] != null
          ? BookingType.fromValue(json['booking_type'] as String)
          : null,
    );
  }
}
