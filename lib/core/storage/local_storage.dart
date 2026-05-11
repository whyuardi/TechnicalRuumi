// lib/core/storage/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('LocalStorage.init() harus dipanggil sebelum menggunakan LocalStorage');
    }
    return _prefs!;
  }

  // ─── Listing Draft ───────────────────────────────────────────────────────────

  static Future<void> saveListingId(String id) =>
      _instance.setString(ApiConstants.keyListingId, id);

  static String? getListingId() => _instance.getString(ApiConstants.keyListingId);

  static Future<void> saveCurrentStep(int step) =>
      _instance.setInt(ApiConstants.keyCurrentStep, step);

  static int getCurrentStep() =>
      _instance.getInt(ApiConstants.keyCurrentStep) ?? 1;

  static Future<void> saveSpaceType(String spaceType) =>
      _instance.setString(ApiConstants.keySpaceType, spaceType);

  static String? getSpaceType() => _instance.getString(ApiConstants.keySpaceType);

  static Future<void> savePropertyTypeId(String id) =>
      _instance.setString(ApiConstants.keyPropertyTypeId, id);

  static String? getPropertyTypeId() =>
      _instance.getString(ApiConstants.keyPropertyTypeId);

  /// Returns true if there's a saved draft to resume
  static bool hasDraft() => getListingId() != null;

  /// Clear all draft data after publishing or canceling
  static Future<void> clearDraft() async {
    await Future.wait([
      _instance.remove(ApiConstants.keyListingId),
      _instance.remove(ApiConstants.keyCurrentStep),
      _instance.remove(ApiConstants.keySpaceType),
      _instance.remove(ApiConstants.keyPropertyTypeId),
    ]);
  }
}
