// ملف: lib/core/services/selection_service.dart
// (النسخة النهائية - جميع الدوال مفعلة ومرتبطة بالـ API)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/selection_models.dart';

class SelectionService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // ----------------------------------------------------
  // ➡️ Helper Function for Fetching Lists
  // ----------------------------------------------------
  Future<List<T>> _fetchList<T>(
      String urlPath,
      String token,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    final url = Uri.parse('$_baseUrl$urlPath');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        // يدعم استجابة الـ Pagination (content) أو القائمة المباشرة
        final List<dynamic> content = jsonBody['content'] ?? jsonBody;

        return content.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print("❌ Failed to load $urlPath: Status ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Selection Service Exception ($urlPath): $e");
      return [];
    }
  }

  // --- دوال جلب البيانات ---

  // 🛑 1. جلب الشعب حسب المستوى (تم التصحيح والتفعيل)
  Future<List<FiliereSimple>> getFilieresByNiveau(String token, String niveau) async {
    // نقوم بتشفير النص للتعامل مع المسافات والرموز (مثل: Licence d'excellence)
    final encodedNiveau = Uri.encodeComponent(niveau);

    return _fetchList(
      '/api/filieres/degree-type/$encodedNiveau?size=100',
      token,
      FiliereSimple.fromJson,
    );
  }

  // 2. جلب الفصول حسب الشعبة
  Future<List<SemestreSimple>> getSemestresByFiliere(String token, String filiereId) async {
    return _fetchList(
      '/api/semesters?filiereId=$filiereId&size=50',
      token,
      SemestreSimple.fromJson,
    );
  }

  // 3. جلب الوحدات حسب الفصل
  Future<List<ModuleSimple>> getModulesBySemestre(String token, String semestreId) async {
    return _fetchList(
      '/api/modules?semestreId=$semestreId&size=50',
      token,
      ModuleSimple.fromJson,
    );
  }

  // 4. جلب المجموعات حسب الوحدة
  Future<List<GroupeSimple>> getGroupesByModule(String token, String moduleId) async {
    return _fetchList(
      '/api/groups?moduleId=$moduleId&size=50',
      token,
      GroupeSimple.fromJson,
    );
  }

  // 5. جلب جميع الفصول (عام)
  Future<List<SemestreSimple>> getAllSemestres(String token) async {
    return _fetchList(
      '/api/semesters?size=100',
      token,
      SemestreSimple.fromJson,
    );
  }

  // 6. جلب المستويات (يمكن إبقاؤها فارغة لأننا نستخدم قائمة ثابتة الآن في UI)
  Future<List<EnumResponse>> getNiveaux(String token) async {
    return [];
  }

  // 7. جلب أنواع التقييم
  Future<List<EnumResponse>> getEvaluationTypes(String token) async {
    return _fetchList(
      '/api/selection/evaluationTypes',
      token,
      EnumResponse.fromJson,
    );
  }
}