// ملف: lib/core/models/departement.dart
// (النسخة المصححة - كتقرا 'content' من الـ JSON)

import 'dart:convert';

// [تصحيح] هادي هي الفانكشن لي غتصلح كلشي
List<Departement> departementFromJson(String str) {
  // 1. كنديكوديو الـ JSON Object لـ Map
  final jsonData = json.decode(str);

  // 2. كنجيبو اللائحة (List) من الخانة (field) 'content'
  final List<dynamic> content = jsonData['content'];

  // 3. كنحولو (map) ديك اللائحة لـ Departement
  return List<Departement>.from(content.map((x) => Departement.fromJson(x)));
}

// 2. الكلاس ديالنا (كيبقى كيفما هو)
class Departement {
  final String id;
  final String name;
  final String code;
  final String? description;
  final int totalFilieres;
  final int totalProfessors;
  // (هادو غنحتاجوهم من بعد فـ 'Edit')
  final String createdAt;
  final String createdBy;

  Departement({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.totalFilieres,
    required this.totalProfessors,
    required this.createdAt,
    required this.createdBy,
  });

  // 3. الفانكشن لي كتحول JSON لـ 'Departement' (زدنا فيها 2 خانات)
  factory Departement.fromJson(Map<String, dynamic> json) => Departement(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    description: json["description"],
    totalFilieres: json["totalFilieres"],
    totalProfessors: json["totalProfessors"],
    createdAt: json["createdAt"] ?? '', // (احتياط)
    createdBy: json["createdBy"] ?? '', // (احتياط)
  );
}