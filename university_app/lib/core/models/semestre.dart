// ملف: lib/core/models/semestre.dart
// (النسخة النهائية والكاملة)

import 'dart:convert';

// دالة مساعدة لتحليل استجابات الـ API التي تحتوي على قائمة 'content' (مثل Pagination) أو قائمة مباشرة.
List<T> _parseContentList<T>(String str, T Function(Map<String, dynamic>) fromJson) {
  final dynamic jsonData = json.decode(str);

  // الحالة 1: الاستجابة مغلفة داخل كائن يحتوي على مفتاح "content" (Paginated Response)
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
    final List<dynamic> content = jsonData['content'];
    return List<T>.from(content.map((x) => fromJson(x)));
  }

  // الحالة 2: الاستجابة هي قائمة مباشرة
  if (jsonData is List) {
    return List<T>.from(jsonData.map((x) => fromJson(x)));
  }
  return [];
}

// دالة عليا لاستدعاء الـ parser الخاص بالـ Semestre
List<Semestre> semestreFromJson(String str) =>
    _parseContentList(str, Semestre.fromJson);

// ----------------------------------------------------
// ➡️ Semestre Model
// ----------------------------------------------------
class Semestre {
  final String id;
  final String name;
  final String? code; // ✅ الحقل الجديد
  final String academicYear;
  final int semesterNumber;
  final String? filiereName;
  final String? filiereId;
  final bool isActive;

  Semestre({
    required this.id,
    required this.name,
    this.code, // ✅ في الـ Constructor
    required this.academicYear,
    required this.semesterNumber,
    this.filiereName,
    this.filiereId,
    required this.isActive,
  });

  // Factory constructor لتحويل JSON إلى كائن Semestre
  factory Semestre.fromJson(Map<String, dynamic> json) => Semestre(
    id: json["id"],
    name: json["name"] ?? 'N/A',
    code: json["code"], // ✅ القراءة من JSON
    academicYear: json["academicYear"] ?? 'N/A',
    semesterNumber: json["semesterNumber"] ?? 0,
    filiereName: json["filiereName"],
    filiereId: json["filiereId"],
    isActive: json["isActive"] ?? false,
  );
}