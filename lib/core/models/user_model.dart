import 'package:equatable/equatable.dart';

/// User model representing student data
class UserModel extends Equatable {
  final String id;
  final String name;
  final String? fullName;
  final String? nameAr;
  final String? nameEn;
  final String email;
  final String? phone;
  final String? studentId;
  final String? major;
  final String? year;
  final String? semester;
  final double? gpa;
  final int? completedCreditHours;
  final int? remainingCreditHours;
  final int? totalCreditHours;
  final double? overallProgress;
  final String? profilePictureUrl;

  const UserModel({
    required this.id,
    required this.name,
    this.fullName,
    this.nameAr,
    this.nameEn,
    required this.email,
    this.phone,
    this.studentId,
    this.major,
    this.year,
    this.semester,
    this.gpa,
    this.completedCreditHours,
    this.remainingCreditHours,
    this.totalCreditHours,
    this.overallProgress,
    this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['studentID']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      nameAr: json['nameAr']?.toString(),
      nameEn: json['nameEn']?.toString(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      studentId: json['studentID']?.toString() ?? json['studentId']?.toString() ?? json['studentCode']?.toString(),
      major: json['major']?.toString() ?? json['department']?.toString(),
      year: json['year']?.toString() ?? json['level']?.toString(),
      semester: json['semester']?.toString(),
      gpa: _toDouble(json['gpa'] ?? json['GPA'] ?? json['gba']),
      completedCreditHours: _toInt(
        json['completedCreditHours'] ?? json['completedHours'],
      ),
      remainingCreditHours: _toInt(
        json['remainingCreditHours'] ?? json['remainingHours'],
      ),
      totalCreditHours: _toInt(json['totalCreditHours'] ?? json['totalHours']),
      overallProgress: _toDouble(json['overallProgress']),
      profilePictureUrl:
          json['profilePictureUrl']?.toString() ??
          json['profilePicture']?.toString() ??
          json['imageUrl']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'major': major,
      'year': year,
      'semester': semester,
      'gpa': gpa,
      'completedCreditHours': completedCreditHours,
      'remainingCreditHours': remainingCreditHours,
      'totalCreditHours': totalCreditHours,
      'overallProgress': overallProgress,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? fullName,
    String? nameAr,
    String? nameEn,
    String? email,
    String? phone,
    String? studentId,
    String? major,
    String? year,
    String? semester,
    double? gpa,
    int? completedCreditHours,
    int? remainingCreditHours,
    int? totalCreditHours,
    double? overallProgress,
    String? profilePictureUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      gpa: gpa ?? this.gpa,
      completedCreditHours: completedCreditHours ?? this.completedCreditHours,
      remainingCreditHours: remainingCreditHours ?? this.remainingCreditHours,
      totalCreditHours: totalCreditHours ?? this.totalCreditHours,
      overallProgress: overallProgress ?? this.overallProgress,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    fullName,
    nameAr,
    nameEn,
    email,
    phone,
    studentId,
    major,
    year,
    semester,
    gpa,
    completedCreditHours,
    remainingCreditHours,
    totalCreditHours,
    overallProgress,
    profilePictureUrl,
  ];

  String getLocalizedName(String langCode) {
    if (langCode == 'ar') {
      return (nameAr != null && nameAr!.isNotEmpty) ? nameAr! : (fullName ?? name);
    }
    return (nameEn != null && nameEn!.isNotEmpty) ? nameEn! : (fullName ?? name);
  }
}
