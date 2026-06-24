import 'package:equatable/equatable.dart';

/// Represents the status of a course enrollment
enum CourseStatusType {
  registered,
  waiting,
  prerequisiteRequired,
  available,
  unknown,
}

/// Represents a single course with localization support
class CourseModel extends Equatable {
  /// Unique identifier for the course
  final String courseID;

  /// Course name in English (primary field from API)
  final String courseNameEn;

  /// Course name in Arabic (nullable - may not be provided by API)
  final String? courseNameAr;

  /// Credit hours for the course
  final int creditHours;

  /// Course registration status (can come from API or be determined locally)
  final CourseStatusType status;

  /// Additional status information (e.g., queue position for waiting status)
  final String? statusInfo;

  /// Prerequisite requirement message (if status is prerequisiteRequired)
  final String? prerequisiteMessage;

  const CourseModel({
    required this.courseID,
    required this.courseNameEn,
    this.courseNameAr,
    required this.creditHours,
    this.status = CourseStatusType.unknown,
    this.statusInfo,
    this.prerequisiteMessage,
  });

  /// Parse CourseModel from JSON API response
  /// Handles multiple field name variations and safe type conversion
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse courseID - keep as String
      final courseID = _safeToString(json['courseID'] ?? json['id'] ?? '');

      // Parse English course name (required from API)
      final courseNameEn = _safeToString(
        json['courseNameEn'] ??
            json['courseNameEN'] ??
            json['englishName'] ??
            json['name_en'] ??
            json['nameEn'] ??
            '',
      );

      // Parse Arabic course name (nullable - may be missing or null from API)
      final courseNameAr = _safeToStringNullable(
        json['courseNameAr'] ??
            json['courseNameAR'] ??
            json['arabicName'] ??
            json['name_ar'] ??
            json['nameAr'],
      );

      // Parse credit hours - safe conversion from any type
      final creditHours = _safeToInt(
        json['creditHours'] ?? json['credit_hours'] ?? 0,
      );

      // Parse status if available from API
      final statusStr = _safeToString(json['status'] ?? '').toLowerCase();
      final status = _parseStatus(statusStr);

      // Parse status info (e.g., queue position)
      final statusInfo = _safeToStringNullable(
        json['statusInfo'] ?? json['queuePosition'],
      );

      // Parse prerequisite message if available
      final prerequisiteMessage = _safeToStringNullable(
        json['prerequisiteMessage'] ?? json['prerequisiteInfo'],
      );

      return CourseModel(
        courseID: courseID,
        courseNameEn: courseNameEn,
        courseNameAr: courseNameAr,
        creditHours: creditHours,
        status: status,
        statusInfo: statusInfo,
        prerequisiteMessage: prerequisiteMessage,
      );
    } catch (e) {
      // Fallback with defaults to prevent crashes
      return CourseModel(
        courseID: _safeToString(json['courseID'] ?? json['id'] ?? 'unknown'),
        courseNameEn: _safeToString(json['courseNameEn'] ?? 'Unknown Course'),
        courseNameAr: null,
        creditHours: 0,
        status: CourseStatusType.unknown,
      );
    }
  }

  /// Parse status string to CourseStatusType enum
  static CourseStatusType _parseStatus(String statusStr) {
    switch (statusStr) {
      case 'registered':
        return CourseStatusType.registered;
      case 'waiting':
        return CourseStatusType.waiting;
      case 'prerequisite_required':
      case 'prerequisiterequired':
        return CourseStatusType.prerequisiteRequired;
      case 'available':
        return CourseStatusType.available;
      default:
        return CourseStatusType.unknown;
    }
  }

  /// Get localized course name based on language code
  /// Priority: Requested language > Fallback to English
  String localizedName(String languageCode) {
    if (languageCode == 'ar') {
      // Arabic requested: use Arabic name if available, otherwise English
      return (courseNameAr != null && courseNameAr!.trim().isNotEmpty)
          ? courseNameAr!.trim()
          : courseNameEn.trim();
    }
    // English or other: use English name
    return courseNameEn.trim();
  }

  /// Safe conversion to int from any type
  /// Handles: null, int, double, String, other types
  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      return parsed ?? 0;
    }
    return 0;
  }

  /// Safe conversion to non-null String
  static String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  /// Safe conversion to nullable String
  static String? _safeToStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    final stringValue = value.toString().trim();
    return stringValue.isNotEmpty ? stringValue : null;
  }

  @override
  List<Object?> get props => [
    courseID,
    courseNameEn,
    courseNameAr,
    creditHours,
    status,
    statusInfo,
    prerequisiteMessage,
  ];
}

/// Represents a semester with multiple courses
class SemesterModel extends Equatable {
  /// Semester number (1, 2, 3, etc.)
  final int semester;

  /// List of courses in this semester
  final List<CourseModel> courses;

  const SemesterModel({required this.semester, required this.courses});

  /// Parse SemesterModel from JSON API response
  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse semester number - safe conversion from any type
      final semester = CourseModel._safeToInt(json['semester'] ?? 0);

      // Parse courses list
      final courses = <CourseModel>[];
      final coursesList = json['courses'];

      if (coursesList is List) {
        for (final courseJson in coursesList) {
          if (courseJson is Map<String, dynamic>) {
            try {
              courses.add(CourseModel.fromJson(courseJson));
            } catch (e) {
              // Skip malformed course entries
              continue;
            }
          }
        }
      }

      return SemesterModel(semester: semester, courses: courses);
    } catch (e) {
      // Fallback to empty semester if parsing fails
      return SemesterModel(semester: 0, courses: []);
    }
  }

  @override
  List<Object?> get props => [semester, courses];
}

/// Represents a level (year) with multiple semesters
class LevelModel extends Equatable {
  /// Level/Year number (1, 2, 3, 4, etc.)
  final int level;

  /// List of semesters in this level
  final List<SemesterModel> semesters;

  const LevelModel({required this.level, required this.semesters});

  /// Parse LevelModel from JSON API response
  factory LevelModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse level number - safe conversion from any type
      final level = CourseModel._safeToInt(json['level'] ?? 0);

      // Parse semesters list
      final semesters = <SemesterModel>[];
      final semestersList = json['semesters'];

      if (semestersList is List) {
        for (final semesterJson in semestersList) {
          if (semesterJson is Map<String, dynamic>) {
            try {
              semesters.add(SemesterModel.fromJson(semesterJson));
            } catch (e) {
              // Skip malformed semester entries
              continue;
            }
          }
        }
      }

      return LevelModel(level: level, semesters: semesters);
    } catch (e) {
      // Fallback to empty level if parsing fails
      return LevelModel(level: 0, semesters: []);
    }
  }

  @override
  List<Object?> get props => [level, semesters];
}
