class AppConstants {
  static const double gpa = 3.75;
  static const int completedCreditHours = 87;
  static const int totalCreditHours = 160;
  static const int remainingCreditHours = 73;
  
  // Profile Info
  static const String studentName = "Shrouk Yassin Mohammed";
  static const String studentId = "20230001";
  static const String studentEmail = "sheroukyassin@45.com";
  static const String studentMajor = "System and Computer";
  static const String studentYear = "Fourth Year";
  static const String studentPhone = "0109017222";

  // Course Mock Data (Expanded)
  static const Map<String, dynamic> courseDetailsMath2 = {
    "code": "ENG102",
    "name": "Math 2",
    "instructors": "Dr. Hassan Mohammed\nDr. Mohammed Ahmmed",
    "creditHours": 2,
    "time": "Thu 4:00 - 6:00",
    "prerequisite": "ENG101",
    "capacity": 25,
    "enrolled": 25, // Full
    "isRegistered": false,
    "hasConflict": true,
  };

  static const List<Map<String, dynamic>> coursesLvl1Sem1 = [
    {"name": "Math 1", "students": 250},
    {"name": "Physics 1", "students": 250},
    {"name": "Mechanics 1 (Static)", "students": 250},
    {"name": "Digital and Logic design 1", "students": 250},
    {"name": "Computer Programming 1", "students": 250},
    {"name": "Islamic Jurisprudence", "students": 250},
  ];

  static const List<Map<String, dynamic>> coursesLvl1Sem2 = [
    {"name": "Math 2", "students": 250},
    {"name": "Physics 2", "students": 250},
    {"name": "Mechanics 2 (Dynamic)", "students": 250},
    {"name": "Digital and Logic design 2", "students": 250},
    {"name": "Computer Programming 2", "students": 250},
    {"name": "The Holy Quran 1", "students": 250},
    {"name": "Islamic Creed and morals", "students": 250},
  ];
}
