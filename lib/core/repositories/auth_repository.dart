import '../models/auth_response.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../utils/app_preferences.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiClient _apiClient;
  final AppPreferences _preferences;

  AuthRepository({ApiClient? apiClient, AppPreferences? preferences})
      : _apiClient = apiClient ?? ApiClient(),
        _preferences = preferences ?? AppPreferences();

  /// Login with email and password
  Future<AuthResponse> login({
    required String studentId,
    required String email,
    required String password,
    required String language,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {
        'studentId': studentId,
        'studentID': studentId,
        'StudentId': studentId,
        'email': email,
        'Email': email,
        'universityEmail': email,
        'UniversityEmail': email,
        'password': password,
        'Password': password,
        'language': language,
        'Language': language,
      },
    );

    final authResponse = AuthResponse.fromJson(response);

    // Save token if login successful
    if (authResponse.token.isNotEmpty) {
      await _preferences.saveToken(authResponse.token);
    }

    return authResponse;
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String year,
    required String language,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      body: {
        'name': name,
        'fullName': name,
        'email': email,
        'Email': email,
        'universityEmail': email,
        'UniversityEmail': email,
        'password': password,
        'studentId': studentId,
        'studentCode': studentId,
        'year': year,
        'level': year,
        'language': language,
        'Language': language,
      },
    );

    final authResponse = AuthResponse.fromJson(response);

    // Save token if registration successful
    if (authResponse.token.isNotEmpty) {
      await _preferences.saveToken(authResponse.token);
    }

    return authResponse;
  }

  /// Logout - clear stored token
  Future<void> logout() async {
    await _preferences.clearToken();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _preferences.isLoggedIn();
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _preferences.getToken();
  }
}
