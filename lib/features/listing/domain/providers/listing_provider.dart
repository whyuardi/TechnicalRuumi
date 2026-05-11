// lib/features/listing/domain/providers/listing_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/listing_repository.dart';
import '../entities/listing_form_state.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository();
});

/// Fetches the host's listings list from the API.
final listingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListings();
});

// ─── Form Notifier Provider ───────────────────────────────────────────────────

final listingFormProvider =
    StateNotifierProvider<ListingFormNotifier, ListingFormState>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  return ListingFormNotifier(repo);
});

// ─── Notifier ────────────────────────────────────────────────────────────────

class ListingFormNotifier extends StateNotifier<ListingFormState> {
  final ListingRepository _repository;

  ListingFormNotifier(this._repository) : super(const ListingFormState()) {
    _restoreDraft();
  }

  // ─── Draft Restoration ────────────────────────────────────────────────────

  void _restoreDraft() {
    final listingId = LocalStorage.getListingId();
    final currentStep = LocalStorage.getCurrentStep();
    if (listingId != null) {
      state = state.copyWith(
        listingId: listingId,
        currentStep: currentStep,
      );
    }
  }

  bool get hasSavedDraft => LocalStorage.hasDraft();
  int get savedStep => LocalStorage.getCurrentStep();

  void resumeDraft() {
    _restoreDraft();
  }

  // ─── Step 1: Load property types ─────────────────────────────────────────

  Future<void> loadPropertyTypes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final types = await _repository.getPropertyTypes();
      state = state.copyWith(isLoading: false, propertyTypes: types);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectPropertyType(dynamic propertyType) {
    state = state.copyWith(selectedPropertyType: propertyType);
  }

  void selectSpaceType(SpaceType spaceType) {
    state = state.copyWith(selectedSpaceType: spaceType);
  }

  /// Create draft and move to step 2
  Future<bool> createDraftAndProceed() async {
    if (state.selectedPropertyType == null) {
      state = state.copyWith(errorMessage: 'Pilih tipe properti terlebih dahulu.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final listing = await _repository.createDraft(
        propertyTypeId: state.selectedPropertyType!.id,
        spaceType: state.selectedSpaceType,
      );

      // Persist to local storage
      await LocalStorage.saveListingId(listing.id);
      await LocalStorage.saveCurrentStep(2);
      await LocalStorage.savePropertyTypeId(state.selectedPropertyType!.id);
      await LocalStorage.saveSpaceType(state.selectedSpaceType.value);

      state = state.copyWith(
        listingId: listing.id,
        currentStep: 2,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Step 2: Location ────────────────────────────────────────────────────

  void updateLocation({
    String? addressLine1,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      addressLine1: addressLine1,
      city: city,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<bool> saveLocationAndProceed() async {
    if (state.listingId == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateListing(
        id: state.listingId!,
        addressLine1: state.addressLine1.isEmpty ? null : state.addressLine1,
        city: state.city.isEmpty ? null : state.city,
        postalCode: state.postalCode.isEmpty ? null : state.postalCode,
        latitude: state.latitude,
        longitude: state.longitude,
      );
      await _goToStep(3);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Step 3: Room Basics ──────────────────────────────────────────────────

  void updateRoomBasics({
    int? maxGuests,
    int? bedrooms,
    double? bathrooms,
    int? propertySize,
  }) {
    state = state.copyWith(
      maxGuests: maxGuests,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      propertySize: propertySize,
    );
  }

  Future<bool> saveRoomBasicsAndProceed() async {
    if (state.listingId == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateListing(
        id: state.listingId!,
        maxGuests: state.maxGuests,
        bedrooms: state.bedrooms,
        bathrooms: state.bathrooms,
        propertySize: state.propertySize,
      );
      await _goToStep(4);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Step 4a: Furnishing ──────────────────────────────────────────────────

  void selectFurnishing(String? type) {
    state = state.copyWith(furnishingType: type);
  }

  Future<void> saveFurnishingAndProceed() async {
    await _goToStep(5);
  }

  // ─── Step 4b: Amenities ───────────────────────────────────────────────────

  void toggleAmenity(String amenity) {
    final current = List<String>.from(state.selectedAmenities);
    if (current.contains(amenity)) {
      current.remove(amenity);
    } else {
      current.add(amenity);
    }
    state = state.copyWith(selectedAmenities: current);
  }

  Future<void> saveAmenitiesAndProceed() async {
    await _goToStep(6);
  }

  // ─── Step 4c: Photos ──────────────────────────────────────────────────────

  void addPhoto(XFile file) {
    final current = List<XFile>.from(state.photoFiles);
    current.add(file);
    state = state.copyWith(photoFiles: current);
  }

  void removePhoto(int index) {
    final current = List<XFile>.from(state.photoFiles);
    current.removeAt(index);
    state = state.copyWith(photoFiles: current);
  }

  Future<void> savePhotosAndProceed() async {
    await _goToStep(7);
  }

  // ─── Step 4d: Title ───────────────────────────────────────────────────────

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  Future<bool> saveTitleAndProceed() async {
    if (state.listingId == null) return false;
    if (state.title.length < 10) {
      state = state.copyWith(errorMessage: 'Judul minimal 10 karakter.');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateListing(
        id: state.listingId!,
        title: state.title,
      );
      await _goToStep(8);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Step 4e: Description ────────────────────────────────────────────────

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  Future<bool> saveDescriptionAndProceed() async {
    if (state.listingId == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Build enriched description including furnishing info and amenities
      String enrichedDesc = state.description;
      if (state.furnishingType != null && state.furnishingType!.isNotEmpty) {
        enrichedDesc = '${state.furnishingType}\n\n$enrichedDesc';
      }
      if (state.selectedAmenities.isNotEmpty) {
        enrichedDesc += '\n\nAmenities: ${state.selectedAmenities.join(', ')}';
      }

      await _repository.updateListing(
        id: state.listingId!,
        description: enrichedDesc.isNotEmpty ? enrichedDesc : null,
      );
      await _goToStep(9);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Step 5a: Booking Type ────────────────────────────────────────────────

  void selectBookingType(BookingType type) {
    state = state.copyWith(bookingType: type);
  }

  Future<bool> saveBookingTypeAndProceed() async {
    if (state.listingId == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateListing(
        id: state.listingId!,
        bookingType: state.bookingType,
      );
      await _goToStep(10);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Step 5b: Price ───────────────────────────────────────────────────────

  void updateBasePrice(double? price) {
    state = state.copyWith(basePrice: price);
  }

  Future<bool> savePriceAndProceed() async {
    if (state.listingId == null) return false;
    if (state.basePrice == null || state.basePrice! <= 0) {
      state = state.copyWith(errorMessage: 'Harga harus lebih besar dari 0.');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateListing(
        id: state.listingId!,
        basePrice: state.basePrice,
      );
      await _goToStep(11);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Publish ─────────────────────────────────────────────────────────────

  Future<bool> publishListing() async {
    if (state.listingId == null) return false;

    // Pre-validate required fields that the API enforces at publish time
    if (state.latitude == null || state.longitude == null) {
      state = state.copyWith(
        errorMessage:
            'Latitude and longitude are required to publish.\n'
            'Please go back to Step 2 (Location) and add coordinates for your property.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.publishListing(state.listingId!);
      await LocalStorage.clearDraft();
      state = state.copyWith(isLoading: false, isPublished: true, currentStep: 13);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  Future<void> _goToStep(int step) async {
    await LocalStorage.saveCurrentStep(step);
    state = state.copyWith(currentStep: step, isLoading: false);
  }

  void goToPreviousStep() {
    if (state.currentStep > 1) {
      final prev = state.currentStep - 1;
      LocalStorage.saveCurrentStep(prev);
      state = state.copyWith(currentStep: prev);
    }
  }

  void navigateToStep(int step) {
    if (step >= 1 && step <= 13) {
      LocalStorage.saveCurrentStep(step);
      state = state.copyWith(currentStep: step);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> startFresh() async {
    await LocalStorage.clearDraft();
    state = const ListingFormState();
  }
}
