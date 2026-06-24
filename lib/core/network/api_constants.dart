/// API Constants for the application
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://credithourssystem.premiumasp.net/api';
  
  // Auth Endpoints
  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  
  // Student Endpoints
  static const String studentProfile = '/Student/profile';
  static const String editProfile = '/Student/edit-student-profile';
  static const String uploadProfileImage = '/Student/edit-student-profile'; // Usually the same or similar
  static const String dashboard = '/Dashboard';
  
  // Course Endpoints
  static const String allCourses = '/Courses/all';
  static const String registerCourse = '/CoursesRegistration/register';
  static const String dropCourse = '/CoursesRegistration/drop';
  static const String mySchedule = '/Schedule/my-schedule';
  static const String myGrades = '/MyGrades';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
