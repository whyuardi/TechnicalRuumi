// lib/features/listing/domain/entities/listing_form_state.dart
import 'package:image_picker/image_picker.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/property_type_model.dart';

class ListingFormState {
  // ─── Draft metadata ─────────────────────────────────────────────────────────
  final String? listingId;
  final int currentStep;   // 1-13 (maps to screen flow)

  // ─── Step 1: Property Type ───────────────────────────────────────────────────
  final List<PropertyTypeModel> propertyTypes;
  final PropertyTypeModel? selectedPropertyType;
  final SpaceType selectedSpaceType;

  // ─── Step 2: Location ────────────────────────────────────────────────────────
  final String addressLine1;
  final String city;
  final String postalCode;
  final double? latitude;
  final double? longitude;

  // ─── Step 3: Room Basics ─────────────────────────────────────────────────────
  final int maxGuests;
  final int bedrooms;
  final double bathrooms;
  final int? propertySize;

  // ─── Step 4a: Furnishing (UI only, appended to description) ─────────────────
  final String? furnishingType;   // 'Unfurnished' | 'Partly furnished' | 'Fully furnished'

  // ─── Step 4b: Amenities (UI only) ────────────────────────────────────────────
  final List<String> selectedAmenities;

  // ─── Step 4c: Photos (XFile for real preview on web/mobile) ────────────────
  final List<XFile> photoFiles;

  // ─── Step 4d: Title ──────────────────────────────────────────────────────────
  final String title;

  // ─── Step 4e: Description ────────────────────────────────────────────────────
  final String description;

  // ─── Step 5a: Booking type ───────────────────────────────────────────────────
  final BookingType bookingType;

  // ─── Step 5b: Price ──────────────────────────────────────────────────────────
  final double? basePrice;

  // ─── UI state ────────────────────────────────────────────────────────────────
  final bool isLoading;
  final String? errorMessage;
  final bool isPublished;

  const ListingFormState({
    this.listingId,
    this.currentStep = 1,
    this.propertyTypes = const [],
    this.selectedPropertyType,
    this.selectedSpaceType = SpaceType.entirePlace,
    this.addressLine1 = '',
    this.city = '',
    this.postalCode = '',
    this.latitude,
    this.longitude,
    this.maxGuests = 1,
    this.bedrooms = 1,
    this.bathrooms = 1.0,
    this.propertySize,
    this.furnishingType,
    this.selectedAmenities = const [],
    this.photoFiles = const [],
    this.title = '',
    this.description = '',
    this.bookingType = BookingType.request,
    this.basePrice,
    this.isLoading = false,
    this.errorMessage,
    this.isPublished = false,
  });

  bool get hasDraft => listingId != null;

  ListingFormState copyWith({
    String? listingId,
    int? currentStep,
    List<PropertyTypeModel>? propertyTypes,
    PropertyTypeModel? selectedPropertyType,
    SpaceType? selectedSpaceType,
    String? addressLine1,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
    int? maxGuests,
    int? bedrooms,
    double? bathrooms,
    int? propertySize,
    String? furnishingType,
    List<String>? selectedAmenities,
    List<XFile>? photoFiles,
    String? title,
    String? description,
    BookingType? bookingType,
    double? basePrice,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isPublished,
  }) {
    return ListingFormState(
      listingId: listingId ?? this.listingId,
      currentStep: currentStep ?? this.currentStep,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      selectedPropertyType: selectedPropertyType ?? this.selectedPropertyType,
      selectedSpaceType: selectedSpaceType ?? this.selectedSpaceType,
      addressLine1: addressLine1 ?? this.addressLine1,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      propertySize: propertySize ?? this.propertySize,
      furnishingType: furnishingType ?? this.furnishingType,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      photoFiles: photoFiles ?? this.photoFiles,
      title: title ?? this.title,
      description: description ?? this.description,
      bookingType: bookingType ?? this.bookingType,
      basePrice: basePrice ?? this.basePrice,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
