// المسار: lib/features/3_professor_role/prof/model/prof_info_model.dart

class ProfInfoModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String grade;
  final String phoneNumber;
  final String specialization;
  final String departmentName;

  ProfInfoModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.grade,
    required this.phoneNumber,
    required this.specialization,
    required this.departmentName,
  });

  // دالة تحويل الـ JSON القادم من الباكند إلى بيانات دارت
  factory ProfInfoModel.fromJson(Map<String, dynamic> json) {
    return ProfInfoModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      grade: json['grade'] ?? 'Non spécifié',
      phoneNumber: json['phoneNumber'] ?? 'Non spécifié',
      specialization: json['specialization'] ?? 'Non spécifié',
      departmentName: json['departmentName'] ?? 'Non spécifié',
    );
  }
}