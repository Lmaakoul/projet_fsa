// ملف: lib/core/models/professor.dart
// (النسخة الكاملة)

import 'dart:convert';

// Hada howa l-JSON l-kbir (PageResponse)
// L-Function katqra "content" mn dak l-JSON
List<Professor> professorFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> content = jsonData['content'];
  return List<Professor>.from(content.map((x) => Professor.fromJson(x)));
}

class Professor {
  final String id;
  final String fullName;
  final String email;
  final String? grade;
  final String? departmentName;
  final bool enabled;
  // (Hado ġaliban (probably) homa l-ism w l-knya)
  final String firstName;
  final String lastName;
  final String departmentId; // (Ghan7tajoha l-l-Edit)

  Professor({
    required this.id,
    required this.fullName,
    required this.email,
    this.grade,
    this.departmentName,
    required this.enabled,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
  });

  factory Professor.fromJson(Map<String, dynamic> json) => Professor(
    id: json["id"],
    fullName: json["fullName"] ?? 'N/A',
    email: json["email"],
    grade: json["grade"],
    departmentName: json["departmentName"],
    enabled: json["enabled"] ?? true,
    firstName: json["firstName"] ?? '', // (Ila kan khawi)
    lastName: json["lastName"] ?? '', // (Ila kan khawi)
    departmentId: json["departmentId"] ?? '', // (Ila kan khawi)
  );
}