import 'package:equatable/equatable.dart';

class DashboardModel extends Equatable {
  final String studentID;
  final String nameEn;
  final String nameAr;
  final double gpa;
  final int completedCreditHours;
  final int remainingCreditHours;
  final double overallProgress;

  const DashboardModel({
    required this.studentID,
    required this.nameEn,
    required this.nameAr,
    required this.gpa,
    required this.completedCreditHours,
    required this.remainingCreditHours,
    required this.overallProgress,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      studentID: (json['studentID'] ?? json['studentId'] ?? json['studentCode'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? json['fullNameEn'] ?? '').toString(),
      nameAr: (json['nameAr'] ?? json['fullNameAr'] ?? '').toString(),
      gpa: _toDouble(json['gpa'] ?? json['gba'] ?? json['GPA'] ?? json['GBA']),
      completedCreditHours: _toInt(json['completedCreditHours'] ?? json['completedHours']),
      remainingCreditHours: _toInt(json['remainingCreditHours'] ?? json['remainingHours']),
      overallProgress: _toDouble(json['overallProgress'] ?? json['progress']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'gpa': gpa,
      'completedCreditHours': completedCreditHours,
      'remainingCreditHours': remainingCreditHours,
      'overallProgress': overallProgress,
    };
  }

  @override
  List<Object?> get props => [
        studentID,
        nameEn,
        nameAr,
        gpa,
        completedCreditHours,
        remainingCreditHours,
        overallProgress,
      ];
}
