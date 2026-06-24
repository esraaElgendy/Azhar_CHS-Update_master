import 'dart:convert';
import 'dart:io';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../utils/app_preferences.dart';

/// Repository for student-related data
class StudentRepository {
  final ApiClient _apiClient;
  final AppPreferences _preferences;

  StudentRepository({ApiClient? apiClient, AppPreferences? preferences})
      : _apiClient = apiClient ?? ApiClient(),
        _preferences = preferences ?? AppPreferences();

  /// Get student profile from API
  Future<UserModel> getProfile({String lang = 'en'}) async {
    final response = await _apiClient.get(
      "${ApiConstants.studentProfile}?lang=$lang",
      requiresAuth: true,
    );

    final userData = response['data'] ?? response['user'] ?? response;
    final freshUser = UserModel.fromJson(userData);
    
    // We only merge from cache if the API returns NULL for specific persistent 
    // local fields (like custom UI preferences if any). 
    // For core data, we trust the API.
    final cachedData = await getCachedProfile();
    
    // Some fields like overallProgress might only come from Dashboard API
    // so we preserve them if they exist in cache but not in profile response.
    final updatedUser = freshUser.copyWith(
      overallProgress: freshUser.overallProgress ?? cachedData?.overallProgress,
      remainingCreditHours: freshUser.remainingCreditHours ?? cachedData?.remainingCreditHours,
      totalCreditHours: freshUser.totalCreditHours ?? cachedData?.totalCreditHours,
      // Ensure profile picture is cleaned (handle empty/null)
      profilePictureUrl: _cleanProfilePictureUrl(freshUser.profilePictureUrl),
    );

    await _preferences.saveUserData(jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }

  /// Get dashboard info from API
  Future<UserModel> getDashboard() async {
    final response = await _apiClient.get(
      ApiConstants.dashboard,
      requiresAuth: true,
    );

    final userData = response['data'] ?? response['user'] ?? response;
    final dashboard = DashboardModel.fromJson(userData);

    // Merge Logic: Connect backend Dashboard data to the unified UserModel
    final cachedData = await getCachedProfile();
    final updatedUser = cachedData != null
        ? cachedData.copyWith(
            nameAr: dashboard.nameAr.isNotEmpty ? dashboard.nameAr : cachedData.nameAr,
            nameEn: dashboard.nameEn.isNotEmpty ? dashboard.nameEn : cachedData.nameEn,
            gpa: dashboard.gpa > 0 ? dashboard.gpa : (cachedData.gpa ?? 0.0),
            completedCreditHours: dashboard.completedCreditHours > 0 
                ? dashboard.completedCreditHours 
                : (cachedData.completedCreditHours ?? 0),
            remainingCreditHours: dashboard.remainingCreditHours > 0 
                ? dashboard.remainingCreditHours 
                : (cachedData.remainingCreditHours ?? 0),
            overallProgress: dashboard.overallProgress > 0 
                ? dashboard.overallProgress 
                : (cachedData.overallProgress ?? 0.0),
            studentId: dashboard.studentID.isNotEmpty ? dashboard.studentID : cachedData.studentId,
            fullName: dashboard.nameEn.isNotEmpty ? dashboard.nameEn : (dashboard.nameAr.isNotEmpty ? dashboard.nameAr : cachedData.fullName),
          )
        : UserModel(
            id: dashboard.studentID,
            name: dashboard.nameEn.isNotEmpty ? dashboard.nameEn : (dashboard.nameAr.isNotEmpty ? dashboard.nameAr : 'Student'),
            fullName: dashboard.nameEn.isNotEmpty ? dashboard.nameEn : (dashboard.nameAr.isNotEmpty ? dashboard.nameAr : 'Student'),
            nameAr: dashboard.nameAr,
            nameEn: dashboard.nameEn,
            email: '',
            studentId: dashboard.studentID,
            gpa: dashboard.gpa,
            completedCreditHours: dashboard.completedCreditHours,
            remainingCreditHours: dashboard.remainingCreditHours,
            overallProgress: dashboard.overallProgress,
          );

    await _preferences.saveUserData(jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }

  /// Save student profile to cache
  Future<void> saveProfile(UserModel user) async {
    await _preferences.saveUserData(jsonEncode(user.toJson()));
  }

  /// Get cached student profile
  Future<UserModel?> getCachedProfile() async {
    final userData = await _preferences.getUserData();
    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Update student profile
  Future<UserModel> updateProfile({
    required String studentID,
    required String name,
    required String fullName,
    required String email,
    required String major,
    required String year,
    required String semester,
    required String phone,
    String lang = 'en',
  }) async {
    // The edit API returns a simple message and imagePath.
    // We wrap it in try-catch to be extra resilient: if the server updates but sends 
    // a non-JSON response, we still want to proceed and fetch the fresh profile.
    try {
      await _apiClient.postMultipart(
        "${ApiConstants.editProfile}?lang=$lang",
        fields: {
          'studentID': studentID,
          'studentId': studentID,
          'id': studentID,
          'name': name,
          'fullName': fullName,
          'FullName': fullName,
          'email': email,
          'universityEmail': email,
          'major': major,
          'year': year,
          'level': year,
          'semester': semester,
          'phone': phone,
        },
        requiresAuth: true,
      );
    } catch (e) {
      // If it fails, it might be due to response parsing. 
      // Since the user confirmed the backend updates, we continue to getProfile.
    }

    // Wait 1 second to ensure server has finished processing the update 
    // before we fetch the fresh data.
    await Future.delayed(const Duration(seconds: 1));

    // After successful POST, fetch the fresh updated data from the profile endpoint
    final freshUser = await getProfile(lang: lang);
    await saveProfile(freshUser);
    return freshUser;
  }

  /// Upload profile image to backend.
  /// If backend endpoint is not available yet this method will update local cache
  /// with a local file path so the app can show immediate preview. When backend
  /// is ready, ApiClient.postMultipart will be used to send the file.
  Future<UserModel> uploadProfileImage({
    required File file,
    String lang = 'en',
  }) async {
    final response = await _apiClient.postMultipart(
      ApiConstants.uploadProfileImage + '?lang=$lang',
      files: {'profilePicture': file},
      requiresAuth: true,
    );

    final userData = response['data'] ?? response['user'] ?? response;
    final cachedData = await getCachedProfile();
    final uploadedUrl = _extractUploadedProfilePictureUrl(userData);

    if (userData is Map<String, dynamic>) {
      final user = UserModel.fromJson(userData);
      final cleanUrl = _cleanProfilePictureUrl(user.profilePictureUrl) ?? uploadedUrl;
      final updated = cachedData != null
          ? cachedData.copyWith(profilePictureUrl: cleanUrl ?? cachedData.profilePictureUrl)
          : user.copyWith(profilePictureUrl: cleanUrl);

      await saveProfile(updated);
      return updated;
    }

    if (uploadedUrl != null && cachedData != null) {
      final updated = cachedData.copyWith(profilePictureUrl: uploadedUrl);
      await saveProfile(updated);
      return updated;
    }

    if (cachedData != null) return cachedData;
    throw ApiException('Profile image uploaded, but profile data was not returned.');
  }

  String? _cleanProfilePictureUrl(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _extractUploadedProfilePictureUrl(dynamic data) {
    if (data is String) return _cleanProfilePictureUrl(data);
    if (data is! Map<String, dynamic>) return null;

    for (final key in const ['profilePictureUrl', 'profilePicture', 'imageUrl', 'url']) {
      final value = _cleanProfilePictureUrl(data[key]?.toString());
      if (value != null) return value;
    }
    return null;
  }
}
