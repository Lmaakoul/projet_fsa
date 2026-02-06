// ملف: lib/core/models/selection_models.dart

import 'dart:convert';

// --------------------------------------------------
// 1. Types Génériques (Niveaux, Types d'Évaluation)
// --------------------------------------------------
class EnumResponse {
  final String value;
  final String label;

  const EnumResponse({required this.value, required this.label});

  factory EnumResponse.fromJson(Map<String, dynamic> json) => EnumResponse(
    value: json["value"] ?? '',
    label: json["label"] ?? 'N/A',
  );
}

// --------------------------------------------------
// 2. Filiere Simple
// --------------------------------------------------
class FiliereSimple {
  final String id;
  final String nom; // الاسم (Name)

  const FiliereSimple({required this.id, required this.nom});

  factory FiliereSimple.fromJson(Map<String, dynamic> json) => FiliereSimple(
    id: json["id"],
    nom: json["name"] ?? 'N/A',
  );
}

// --------------------------------------------------
// 3. Semestre Simple
// --------------------------------------------------
class SemestreSimple {
  final String id;
  final String nom;
  final String filiereId; // 🛑 ضروري للفلترة

  const SemestreSimple({required this.id, required this.nom, required this.filiereId});

  factory SemestreSimple.fromJson(Map<String, dynamic> json) => SemestreSimple(
    id: json["id"],
    nom: json["name"] ?? 'N/A',
    filiereId: json["filiereId"] ?? '',
  );
}

// --------------------------------------------------
// 4. Module Simple
// --------------------------------------------------
class ModuleSimple {
  final String id;
  final String nom;

  const ModuleSimple({required this.id, required this.nom});

  factory ModuleSimple.fromJson(Map<String, dynamic> json) => ModuleSimple(
    id: json["id"],
    nom: json["title"] ?? 'N/A',
  );
}

// --------------------------------------------------
// 5. Groupe Simple
// --------------------------------------------------
class GroupeSimple {
  final String id;
  final String code;

  const GroupeSimple({required this.id, required this.code});

  factory GroupeSimple.fromJson(Map<String, dynamic> json) => GroupeSimple(
    id: json["id"],
    code: json["code"] ?? 'N/A',
  );
}

// 💡 يجب إضافة دوال Parsing من JSON هنا إذا كانت ضرورية.