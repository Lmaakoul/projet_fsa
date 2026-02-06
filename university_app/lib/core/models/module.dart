// ملف: lib/core/models/module.dart
// (النسخة المصححة - فيها Stats)

import 'dart:convert';

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

List<Module> moduleFromJson(String str) =>
    _parseContentList(str, Module.fromJson);

class Module {
  final String id;
  final String title;
  final String code;
  final String? semesterName;
  final String? filiereName;
  final String? semesterId;
  final int credits;
  final double passingGrade;
  final List<ProfessorSimple> professors;

  // [جديد] Zidna l-Stats
  final int totalProfessors;
  final int totalSessions;
  final int totalGroups;
  final int totalEvaluations;

  Module({
    required this.id,
    required this.title,
    required this.code,
    this.semesterName,
    this.filiereName,
    this.semesterId,
    required this.credits,
    required this.passingGrade,
    required this.professors,
    // [جديد]
    required this.totalProfessors,
    required this.totalSessions,
    required this.totalGroups,
    required this.totalEvaluations,
  });

  factory Module.fromJson(Map<String, dynamic> json) => Module(
    id: json["id"],
    title: json["title"] ?? 'N/A',
    code: json["code"] ?? 'N/A',
    semesterName: json["semesterName"],
    filiereName: json["filiereName"],
    semesterId: json["semesterId"],
    credits: json["credits"] ?? 0,
    passingGrade: (json["passingGrade"] ?? 0.0).toDouble(),
    professors: json["professors"] != null
        ? List<ProfessorSimple>.from(json["professors"].map((x) => ProfessorSimple.fromJson(x)))
        : [],
    // [جديد] Kanqraw l-Stats
    totalProfessors: json["totalProfessors"] ?? 0,
    totalSessions: json["totalSessions"] ?? 0,
    totalGroups: json["totalGroups"] ?? 0,
    totalEvaluations: json["totalEvaluations"] ?? 0,
  );
}

class ProfessorSimple {
  final String id;
  final String fullName;

  ProfessorSimple({required this.id, required this.fullName});

  factory ProfessorSimple.fromJson(Map<String, dynamic> json) => ProfessorSimple(
    id: json["id"],
    fullName: json["fullName"] ?? 'N/A',
  );
}