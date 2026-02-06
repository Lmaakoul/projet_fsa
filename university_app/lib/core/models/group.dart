import 'dart:convert';

// (Function mosa3ida dyal JSON parsing)
List<T> _parseContentList<T>(String str, T Function(Map<String, dynamic>) fromJson) {
  final dynamic jsonData = json.decode(str);
  // دعم الـ Pagination (content)
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
    final List<dynamic> content = jsonData['content'];
    return List<T>.from(content.map((x) => fromJson(x)));
  }
  // دعم القائمة المباشرة
  if (jsonData is List) {
    return List<T>.from(jsonData.map((x) => fromJson(x)));
  }
  return [];
}

List<Group> groupFromJson(String str) => _parseContentList(str, Group.fromJson);

class Group {
  final String id;
  final String name;
  final String? code;
  final String? description; // [جديد]
  final String? moduleId;
  final String? moduleTitle;
  final int maxCapacity;      // [جديد] السعة القصوى
  final int currentCapacity;  // [جديد] السعة الحالية
  final int totalStudents;
  final bool isActive;
  final bool isFull;          // [جديد] هل المجموعة ممتلئة؟

  Group({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.moduleId,
    this.moduleTitle,
    required this.maxCapacity,
    required this.currentCapacity,
    required this.totalStudents,
    required this.isActive,
    required this.isFull,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json["id"] ?? '',
    name: json["name"] ?? 'Sans nom',
    code: json["code"],
    description: json["description"],
    moduleId: json["moduleId"],
    moduleTitle: json["moduleTitle"],
    // قراءة الأرقام مع حماية (?? 0)
    maxCapacity: json["maxCapacity"] ?? 0,
    currentCapacity: json["currentCapacity"] ?? 0,
    totalStudents: json["totalStudents"] ?? 0,
    // قراءة البوليان
    isActive: json["isActive"] ?? true,
    isFull: json["isFull"] ?? false,
  );
}