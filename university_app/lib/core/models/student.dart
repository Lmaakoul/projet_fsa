// ملف: lib/core/models/student.dart
// (النسخة الكاملة - فيها كلشي)

import 'dart:convert';

// (Function mosa3ida dyal JSON parsing)
List<T> _parseContentList<T>(String str, T Function(Map<String, dynamic>) fromJson) {
  final dynamic jsonData = json.decode(str);
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
    final List<dynamic> content = jsonData['content'];
    return List<T>.from(content.map((x) => fromJson(x)));
  }
  if (jsonData is List) {
    return List<T>.from(jsonData.map((x) => fromJson(x)));
  }
  return [];
}

List<Student> studentFromJson(String str) =>
    _parseContentList(str, Student.fromJson);

class Student {
  final String id;
  final String fullName;
  final String email;
  final String cne;
  final String cin; // <-- [تصحيح]
  final String? filiereName;
  final String? filiereId;
  final String firstName; // <-- [تصحيح]
  final String lastName; // <-- [تصحيح]
  final String? dateOfBirth; // <-- [تصحيح]

  Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.cne,
    required this.cin,
    this.filiereName,
    this.filiereId,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json["id"],
    fullName: json["fullName"] ?? 'N/A',
    email: json["email"] ?? 'N/A',
    cne: json["cne"] ?? 'N/A',
    cin: json["cin"] ?? 'N/A',
    filiereName: json["filiereName"],
    filiereId: json["filiereId"],
    firstName: json["firstName"] ?? '',
    lastName: json["lastName"] ?? '',
    dateOfBirth: json["dateOfBirth"],
  );
}