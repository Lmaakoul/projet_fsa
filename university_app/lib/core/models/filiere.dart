// ملف: lib/core/models/filiere.dart

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

List<Filiere> filiereFromJson(String str) =>
    _parseContentList(str, Filiere.fromJson);

class Filiere {
  final String id;
  final String name;
  final String code;
  final String degreeType; // (Niveau: DEUG, LICENCE...)
  final String? departmentName;
  final String? departmentId;
  final int durationYears;

  Filiere({
    required this.id,
    required this.name,
    required this.code,
    required this.degreeType,
    this.departmentName,
    this.departmentId,
    required this.durationYears,
  });

  // Hada kayqra l-JSON li 3ṭitini
  factory Filiere.fromJson(Map<String, dynamic> json) => Filiere(
    id: json["id"],
    name: json["name"] ?? 'N/A',
    code: json["code"] ?? 'N/A',
    degreeType: json["degreeType"] ?? 'N/A',
    departmentName: json["departmentName"],
    departmentId: json["departmentId"],
    durationYears: json["durationYears"] ?? 0,
  );
}