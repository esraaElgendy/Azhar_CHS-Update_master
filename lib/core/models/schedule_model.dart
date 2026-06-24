import 'package:equatable/equatable.dart';

class ScheduleModel extends Equatable {
  final String scheduleID;
  final String courseID;
  final String courseName;
  final String instructorName;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String sessionType;

  const ScheduleModel({
    required this.scheduleID,
    required this.courseID,
    required this.courseName,
    required this.instructorName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.sessionType,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      scheduleID: (json['scheduleID'] ?? json['id'] ?? '').toString(),
      courseID: (json['courseID'] ?? '').toString(),
      courseName: json['courseName'] ?? json['courseNameEn'] ?? '',
      instructorName: json['instructorName'] ?? '',
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      room: json['room'] ?? '',
      sessionType: json['sessionType'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        scheduleID,
        courseID,
        courseName,
        instructorName,
        day,
        startTime,
        endTime,
        room,
        sessionType,
      ];
}
