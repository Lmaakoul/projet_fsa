import 'dart:convert';

// دالة المساعدة (صحيحة 100%)
List<Evaluation> evaluationFromJson(String str) {
  final dynamic jsonData = json.decode(str);
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
    final List<dynamic> content = jsonData['content'];
    return List<Evaluation>.from(content.map((x) => Evaluation.fromJson(x)));
  }
  if (jsonData is List) {
    return List<Evaluation>.from(jsonData.map((x) => Evaluation.fromJson(x)));
  }
  return [];
}

class Evaluation {
  final String id;
  final String type;
  final double grade;
  final double maxGrade;
  final double coefficient; // ✅ [مضاف] مهم للحسابات
  final bool isValidated;
  final String studentName;
  final String studentCne;
  final String moduleTitle; // ✅ [مضاف] للعرض
  final String date;

  Evaluation({
    required this.id,
    required this.type,
    required this.grade,
    required this.maxGrade,
    required this.coefficient,
    required this.isValidated,
    required this.studentName,
    required this.studentCne,
    required this.moduleTitle,
    required this.date,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) => Evaluation(
    id: json["id"] ?? '',
    type: json["type"] ?? 'N/A',
    grade: (json["grade"] ?? 0.0).toDouble(),
    maxGrade: (json["maxGrade"] ?? 20.0).toDouble(),
    coefficient: (json["coefficient"] ?? 1.0).toDouble(), // ✅ قراءة المعامل
    isValidated: json["isValidated"] ?? false,
    studentName: json["studentName"] ?? 'Inconnu',
    studentCne: json["studentCne"] ?? 'N/A',
    moduleTitle: json["moduleTitle"] ?? '', // ✅ قراءة اسم المادة
    date: json["date"] ?? '',
  );
}