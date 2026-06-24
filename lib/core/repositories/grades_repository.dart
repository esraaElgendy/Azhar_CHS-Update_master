import '../models/grades_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

class GradesRepository {
  final ApiClient _apiClient;

  GradesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<GradesSummaryModel> getMyGrades({required String lang}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.myGrades}?language=$lang',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        return GradesSummaryModel.fromJson(data);
      } else {
        throw Exception(response['message'] ?? 'Failed to load grades');
      }
    } catch (e) {
      rethrow;
    }
  }
}
