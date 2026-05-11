# RUUMI Property Listing App 🏠

A Flutter application implementing the **Draft-to-Publish** property listing flow for RUUMI PropTech Technical Test.

---

## 📱 App Screenshots

> App flow: Home → Getting Started → 10-Step Form → Publish

| Home | Getting Started | Property Type | Location |
|------|----------------|---------------|----------|
| Empty state with + button | 3-step intro | Grid of property types | Address form with optional coordinates |

| Room Basics | Furnishing | Amenities | Photos |
|-------------|-----------|-----------|--------|
| Counter steppers ±  | Radio selection | Chip grid with show more | Photo upload with progress |

| Title | Description | Booking Type | Price |
|-------|-------------|-------------|-------|
| 10-32 char counter | 500 char textarea | Instant/Request toggle | Live breakdown |

| Publish |
|---------|
| Summary card + animated building + error dialog |

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extension
- Physical device or emulator (Android/iOS)

### Steps

```bash
# 1. Clone / navigate to project
cd ruumi_listing

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run

# 4. (Optional) Build APK
flutter build apk --release
```

---

## 🏗️ Architecture

### State Management: **Riverpod**

Dipilih karena:
- **Compile-safe**: Error terdeteksi saat compile, bukan runtime
- **Testable**: Provider mudah di-override untuk unit test
- **No BuildContext dependency**: Tidak perlu context untuk membaca/menulis state

```
ListingFormNotifier (StateNotifier<ListingFormState>)
├── Holds all form data (10 steps)
├── Calls API via ListingRepository
└── Persists step to SharedPreferences after each action
```

### Architecture: **Feature-first + Repository Pattern**

```
lib/
├── core/
│   ├── constants/      # Colors, API URLs, storage keys
│   ├── error/          # Custom exception hierarchy
│   ├── network/        # Dio client + interceptors
│   └── storage/        # SharedPreferences wrapper
└── features/
    └── listing/
        ├── data/
        │   ├── models/       # PropertyTypeModel, ListingModel, Enums
        │   └── repositories/ # ListingRepository (API calls)
        ├── domain/
        │   ├── entities/     # ListingFormState
        │   └── providers/    # ListingFormNotifier (Riverpod)
        └── presentation/
            ├── pages/        # 13 step pages
            └── widgets/      # Reusable widgets
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `dio` | ^5.4.3 | HTTP client |
| `shared_preferences` | ^2.2.3 | Local draft persistence |
| `go_router` | ^14.2.0 | Navigation |
| `google_fonts` | ^6.2.1 | Inter font |

---

## 🔄 Draft-to-Publish Flow

```
[Step 1]  Select Property Type + Space Type
             → POST /api/v1/listings/
             → Save listing_id + current_step to SharedPreferences
             
[Step 2]  Location (address, city, zip, optional lat/lng)
             → PATCH /api/v1/listings/{id}
             
[Step 3]  Room Basics (guests, bedrooms, bathrooms, size)
             → PATCH /api/v1/listings/{id}
             
[Step 4a] Furnishing (radio selection)
[Step 4b] Amenities (chip selection)
[Step 4c] Photos (UI, triggers 422 on publish)
[Step 4d] Title (10-32 chars)   → PATCH /api/v1/listings/{id}
[Step 4e] Description (0-500)   → PATCH /api/v1/listings/{id}

[Step 5a] Booking Type (INSTANT/REQUEST) → PATCH /api/v1/listings/{id}
[Step 5b] Price (base_price > 0)         → PATCH /api/v1/listings/{id}

[Publish] Summary → POST /api/v1/listings/{id}/publish
             → Handle 422 errors elegantly (Dialog + Snackbar)
             → Clear draft on success
```

---

## 💾 Draft Resumption (Force-Close Test)

### Implementation

```dart
// main.dart - runs before app starts
await LocalStorage.init();
// LocalStorage reads SharedPreferences synchronously after init

// In ListingFormNotifier constructor:
void _restoreDraft() {
  final listingId = LocalStorage.getListingId();   // e.g. "uuid-1234"
  final currentStep = LocalStorage.getCurrentStep(); // e.g. 3
  if (listingId != null) {
    state = state.copyWith(listingId: listingId, currentStep: currentStep);
  }
}
```

Every time the user moves to a new step:

```dart
Future<void> _goToStep(int step) async {
  await LocalStorage.saveCurrentStep(step); // ← persisted to disk immediately
  state = state.copyWith(currentStep: step, isLoading: false);
}
```

### How to Test the Force-Close Scenario

1. **Open the app** → tap **+** → tap **Get Started** → **Fill in RUUMI App**
2. **Complete Step 1** (select property type + space type, tap Next)  
   → At this point, `listing_id` and `current_step=2` are saved locally
3. **Continue to Step 3** (location and room basics)  
   → `current_step=3` is now saved
4. **Force-close the app** (Android: swipe away from recent apps / iOS: swipe up and flick)
5. **Reopen the app** → The home screen immediately shows a **"Resume Draft?"** dialog with the saved step number
6. Tap **Continue** → App navigates directly to **Step 3** without restarting
7. Tap **Start Over** → Clears the draft and starts fresh from Getting Started

### Proof

The `listing_id` and `current_step` are written to SharedPreferences **synchronously** after every successful API call. SharedPreferences data survives force-closes, memory kills, and device restarts. The `LocalStorage.init()` call in `main()` ensures data is available before any widget renders.

---

## ⚙️ API Validation Handling

### Latitude + Longitude Pair

Client-side validation in `Step2LocationPage`:
```dart
if (_latCtrl.text.isNotEmpty && _lngCtrl.text.isEmpty ||
    _latCtrl.text.isEmpty && _lngCtrl.text.isNotEmpty) {
  // Show Snackbar: "Latitude dan longitude harus diisi bersama-sama."
}
```

Also enforced in `ListingRepository.updateListing()`:
```dart
if (latitude != null && longitude == null || latitude == null && longitude != null) {
  throw ServerException(message: 'Latitude dan longitude harus dikirim bersama-sama.');
}
```

### base_price > 0

Client-side in `Step5bPricePage`:
```dart
bool get _isValid => _price != null && _price! > 0;
// Next button is disabled when !_isValid
```

Also validated in `ListingFormNotifier.savePriceAndProceed()`.

### 422 Error from Publish

```dart
// In ListingFormNotifier.publishListing():
} on DioException catch (e) {
  if (e.response?.statusCode == 422) {
    final detail = e.response?.data['detail'];
    state = state.copyWith(errorMessage: detail.toString());
    // UI listens to errorMessage and shows AlertDialog
  }
}
```

The `PublishPage` listens to `errorMessage` and shows an **AlertDialog** (not just a Snackbar) to ensure visibility of important messages like "Minimum 5 photos required".

---

## 🌐 Network Handling

- **Loading state**: `LoadingOverlay` widget covers the screen during all API calls
- **Timeout**: 20s connect, 30s receive via Dio `BaseOptions`
- **Retry**: Empty state on Step 1 with "Coba lagi" button if property types fail to load
- **Offline**: `NetworkException` shown via Snackbar with descriptive message
- **Interceptor**: `_ErrorInterceptor` converts all `DioException` types to custom `AppException` subclasses

---

## 📝 Notes

- The API does not require authentication (no Bearer token in OpenAPI spec)
- Photos endpoint not in API spec — photo count is tracked UI-only and triggers 422 from `/publish`  
- Price breakdown (guest service fee, taxes, host fee) is calculated client-side as a UX feature
