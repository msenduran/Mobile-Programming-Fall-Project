import 'package:shared_preferences/shared_preferences.dart';

/// Stores the active house and member IDs on this device.
///
/// The house and member records themselves stay in SQLite; this service only
/// remembers which records are currently selected.
class PreferencesService {
  static const _currentHouseIdKey = 'currentHouseId';
  static const _currentMemberIdKey = 'currentMemberId';

  Future<String?> getCurrentHouseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentHouseIdKey);
  }

  Future<bool> setCurrentHouseId(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_currentHouseIdKey, houseId);
  }

  Future<bool> clearCurrentHouseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_currentHouseIdKey);
  }

  Future<String?> getCurrentMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentMemberIdKey);
  }

  Future<bool> setCurrentMemberId(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_currentMemberIdKey, memberId);
  }

  Future<bool> clearCurrentMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_currentMemberIdKey);
  }
}