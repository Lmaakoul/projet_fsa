// ملف: lib/core/models/salle.dart

import 'dart:convert';

// دالة التحويل من JSON
List<Salle> salleFromJson(String str) {
  final jsonData = json.decode(str);
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
    return List<Salle>.from(jsonData['content'].map((x) => Salle.fromJson(x)));
  }
  if (jsonData is List) {
    return List<Salle>.from(jsonData.map((x) => Salle.fromJson(x)));
  }
  return [];
}

class Salle {
  final String id;
  final String code;          // roomNumber
  final String departmentName;
  final String building;
  final int capacity;
  final String type;

  Salle({
    required this.id,
    required this.code,
    required this.departmentName,
    required this.building,
    required this.capacity,
    required this.type,
  });

  factory Salle.fromJson(Map<String, dynamic> json) => Salle(
    id: json["id"] ?? '',
    code: json["roomNumber"] ?? json["name"] ?? 'Salle',
    departmentName: json["departmentName"] ?? 'Général',
    building: json["building"] ?? '',
    capacity: json["capacity"] ?? 0,
    type: json["roomType"] ?? '',
  );
}