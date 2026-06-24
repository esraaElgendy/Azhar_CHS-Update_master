import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  static const String _keyTheme = 'theme_mode';
  static const String _keyLocale = 'locale';
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyRegisteredCourses = 'registered_courses';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(_keyTheme, isDark);
  }

  bool? getThemeMode() {
    return _prefs.getBool(_keyTheme);
  }

  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_keyLocale, languageCode);
  }

  String? getLocale() {
    return _prefs.getString(_keyLocale);
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserData);
    await _prefs.remove(_keyRegisteredCourses);
  }

  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // User data caching
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(_keyUserData, userData);
  }

  String? getUserData() {
    return _prefs.getString(_keyUserData);
  }

  // Registered Courses Persistence
  Future<void> setRegisteredCourses(List<String> courseIds) async {
    await _prefs.setStringList(_keyRegisteredCourses, courseIds);
  }

  List<String> getRegisteredCourses() {
    return _prefs.getStringList(_keyRegisteredCourses) ?? [];
  }
}
