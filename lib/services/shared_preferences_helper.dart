import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();
  static final SharedPreferencesHelper instance = SharedPreferencesHelper._();

  static String adminIdKey = 'ADMINIDKEY';
  static String adminNameKey = 'ADMINNAMEKEY';
  static String adminEmailKey = 'ADMINEMAILKEY';
  static String adminImageUrlKey = 'ADMINIMAGEURLKEY';

  Future<bool> saveAdminId(String adminId) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminIdKey, adminId);
  }

  Future<bool> saveAdminName(String adminName) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminNameKey, adminName);
  }

  Future<bool> saveAdminEmail(String adminEmail) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminEmailKey, adminEmail);
  }

  Future<bool> saveAdminImageUrl(String adminImageUrl) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminImageUrl, adminImageUrl);
  }

  Future<String?> getAdminId() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminIdKey);
  }

  Future<String?> getAdminName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminNameKey);
  }

  Future<String?> getAdminEmail() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminEmailKey);
  }

  Future<String?> getAdminImgUrl() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminImageUrlKey);
  }

  Future<void> clearAll() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(adminIdKey);
    await pref.remove(adminNameKey);
    await pref.remove(adminEmailKey);
    await pref.remove(adminImageUrlKey);
  }
}
