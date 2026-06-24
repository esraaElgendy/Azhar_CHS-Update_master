import 'package:equatable/equatable.dart';

class CourseGradeModel extends Equatable {
  final String courseID;
  final String courseName;
  final num numericGrade;
  final String letterGrade;
  final num gradePoints;
  final num percentage;
  final String academicYear;
  final String semester;
  final String status;

  const CourseGradeModel({
    required this.courseID,
    required this.courseName,
    required this.numericGrade,
    required this.letterGrade,
    required this.gradePoints,
    required this.percentage,
    required this.academicYear,
    required this.semester,
    required this.status,
  });

  factory CourseGradeModel.fromJson(Map<String, dynamic> json) {
    return CourseGradeModel(
      courseID: (json['courseID'] ?? '').toString(),
      courseName: json['courseName'] ?? '',
      numericGrade: json['numericGrade'] ?? 0,
      letterGrade: json['letterGrade'] ?? '-',
      gradePoints: json['gradePoints'] ?? 0,
      percentage: json['percentage'] ?? 0,
      academicYear: (json['academicYear'] ?? '').toString(),
      semester: (json['semester'] ?? '').toString(),
      status: json['status'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        courseID,
        courseName,
        numericGrade,
        letterGrade,
        gradePoints,
        percentage,
        academicYear,
        semester,
        status,
      ];
}

class SemesterGradesModel extends Equatable {
  final String term;
  final List<CourseGradeModel> courses;

  const SemesterGradesModel({
    required this.term,
    required this.courses,
  });

  factory SemesterGradesModel.fromJson(Map<String, dynamic> json) {
    final coursesList = json['courses'] as List? ?? [];
    return SemesterGradesModel(
      term: json['term'] ?? '',
      courses: coursesList.map((c) => CourseGradeModel.fromJson(c)).toList(),
    );
  }

  @override
  List<Object?> get props => [term, courses];
}

class GradesSummaryModel extends Equatable {
  final num gpa;
  final num totalGradePoints;
  final num totalPercentage;
  final String overallLetter;
  final List<SemesterGradesModel> semesterGrades;

  const GradesSummaryModel({
    required this.gpa,
    required this.totalGradePoints,
    required this.totalPercentage,
    required this.overallLetter,
    required this.semesterGrades,
  });

  factory GradesSummaryModel.fromJson(Map<String, dynamic> json) {
    final semesterGradesList = json['semesterGrades'] as List? ?? [];
    return GradesSummaryModel(
      gpa: json['gpa'] ?? 0,
      totalGradePoints: json['totalGradePoints'] ?? 0,
      totalPercentage: json['totalPercentage'] ?? 0,
      overallLetter: json['overallLetter'] ?? '-',
      semesterGrades: semesterGradesList
          .map((s) => SemesterGradesModel.fromJson(s))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        gpa,
        totalGradePoints,
        totalPercentage,
        overallLetter,
        semesterGrades,
      ];
}
