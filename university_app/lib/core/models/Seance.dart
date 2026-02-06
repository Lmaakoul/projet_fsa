import 'dart:convert';

// 🛠️ التعديل هنا: فحص البيانات إذا كانت داخل 'content' أم لا
List<Seance> seanceFromJson(String str) {
  final jsonData = json.decode(str);
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
    return List<Seance>.from(jsonData['content'].map((x) => Seance.fromJson(x)));
  } else if (jsonData is List) {
    return List<Seance>.from(jsonData.map((x) => Seance.fromJson(x)));
  } else {
    return [];
  }
}

class Seance {
  final String id;
  final String name;
  final String type;
  final DateTime schedule;
  final int duration;
  final bool isCompleted;
  final bool attendanceTaken;

  // جعلنا هذه الحقول تقبل null (?) لتجنب الأخطاء
  final String? locationName;
  final String? locationBuilding;
  final String? professorName;
  final String? moduleTitle;

  // الجروب إجباري (non-nullable)
  final String groupName;

  Seance({
    required this.id,
    required this.name,
    required this.type,
    required this.schedule,
    required this.duration,
    required this.isCompleted,
    required this.attendanceTaken,
    this.locationName,
    this.locationBuilding,
    this.professorName,
    this.moduleTitle,
    required this.groupName,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    // 1. استخراج اسم الجروب بأمان
    String gName = "Groupe ??";
    if (json["groupName"] != null) {
      gName = json["groupName"];
    } else if (json["groups"] != null && (json["groups"] as List).isNotEmpty) {
      gName = (json["groups"] as List)
          .map((g) => g["name"] ?? g["code"] ?? "")
          .join(", ");
    } else if (json["groupe"] != null && json["groupe"] is Map) {
      gName = json["groupe"]["name"] ?? json["groupe"]["code"] ?? "Groupe";
    } else if (json["groupeCode"] != null) {
      gName = json["groupeCode"];
    }

    // 2. معالجة التاريخ
    DateTime date = DateTime.now();
    if (json['schedule'] != null) {
      date = DateTime.parse(json['schedule']);
    } else if (json['startTime'] != null) {
      date = DateTime.parse(json['startTime']);
    } else if (json['start_time'] != null) {
      date = DateTime.parse(json['start_time']);
    }

    // 3. معالجة القاعة لتجنب خطأ String?
    String? locName = json['locationName'];
    if (locName == null && json['salle'] != null) {
      locName = json['salle']['name'];
    }

    return Seance(
      id: json['id'].toString(),
      name: json['name'] ?? json['label'] ?? json['moduleName'] ?? "Séance",
      type: json['type'] ?? "AUTRE",
      schedule: date.toLocal(),
      duration: json['duration'] ?? 60,
      isCompleted: json['isCompleted'] ?? json['status'] == 'COMPLETED' ?? false,
      attendanceTaken: json['attendanceTaken'] ?? false,
      locationName: locName,
      locationBuilding: json['locationBuilding'],
      professorName: json['professorName'],
      moduleTitle: json['moduleTitle'],
      groupName: gName,
    );
  }
}