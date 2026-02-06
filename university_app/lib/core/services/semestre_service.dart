// ملف: lib/core/services/semestre_service.dart
// (النسخة النهائية والمكتملة)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/semestre.dart';
// 🛑 تأكد من إضافة هذا الـ Import إذا كنت تستخدم دالة Pagination
// import '../models/paginated_semestre_response.dart';

class SemestreService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // --- 1. GET ALL (بدون ترقيم) ---
  Future<List<Semestre>> getAllSemestres(String token) async {
    final url = Uri.parse('$_baseUrl/api/semesters?page=0&size=100');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return semestreFromJson(response.body);
      } else {
        print("❌ Failed to load semestres: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Semestre Service Exception (GET): $e");
      return [];
    }
  }

  // 🛑 [ملاحظة]: يمكن إضافة دالة getSemestresPaginated هنا إذا كنت تحتاج إلى الترقيم
  /*
  Future<PaginatedSemestreResponse?> getSemestresPaginated(...) async {
    // ... (كود الترقيم الذي قدمته سابقًا)
  }
  */

  // --- 2. CREATE (POST) ---
  Future<String?> createSemestre({
    required String token,
    required String name,
    String? code, // ✅ تمت إضافة الحقل لتضمينه في الـ Request Body
    required String academicYear,
    required int semesterNumber,
    required String filiereId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/semesters');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "code": code, // ✅ إرسال حقل code
          "academicYear": academicYear,
          "semesterNumber": semesterNumber,
          "filiereId": filiereId,
          "isActive": true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Semestre Created Successfully");
        return null;
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print("❌ Semestre Service Exception (POST): $e");
      return "Problème de connexion: ${e.toString()}";
    }
  }

  // --- 3. UPDATE (PUT) ---
  Future<String?> updateSemestre({
    required String token,
    required String id,
    required String name,
    String? code, // ✅ تمت إضافة الحقل للتحديث
    required String academicYear,
    required int semesterNumber,
    required String filiereId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/semesters/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "code": code, // ✅ إرسال حقل code للتحديث
          "academicYear": academicYear,
          "semesterNumber": semesterNumber,
          "filiereId": filiereId,
          "isActive": true,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Semestre Updated Successfully");
        return null;
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print("❌ Semestre Service Exception (PUT): $e");
      return "Problème de connexion: ${e.toString()}";
    }
  }

  // --- 4. DELETE ---
  Future<String?> deleteSemestre({
    required String token,
    required String semestreId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/semesters/$semestreId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Semestre Deleted Successfully");
        return null;
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print("❌ Semestre Service Exception (DELETE): $e");
      return "Problème de connexion: ${e.toString()}";
    }
  }

  // -----------------------------------------------------------------
  // 5. Centralized Error Handling (معالجة الأخطاء المركزية)
  // -----------------------------------------------------------------
  String? _handleErrorResponse(http.Response response) {
    print("❌ Failed request with status code: ${response.statusCode}");

    if (response.body.isEmpty) {
      return "Erreur du serveur (Code: ${response.statusCode}) - لا توجد رسالة.";
    }

    try {
      final body = json.decode(response.body);
      final String rawMessage = body['message'] ?? body['error'] ?? "Erreur inconnue (Code: ${response.statusCode})";

      return _translateError(rawMessage);

    } catch (e) {
      print("❌ JSON Decode Error: $e");
      return "Erreur de format de réponse du serveur (Code: ${response.statusCode})";
    }
  }

  // 6. Error Translation (ترجمة الأخطاء)
  String _translateError(String englishMessage) {
    if (englishMessage.contains("module(s) associated")) {
      final number = RegExp(r'(\d+)').firstMatch(englishMessage)?.group(1);
      return "Impossible de supprimer: Ce semestre est associé إلى $number module(s).";
    }
    if (englishMessage.contains("Semester number") && englishMessage.contains("already exists")) {
      return "Échec: Ce numéro de semestre موجود بالفعل لهذه الشعبة (filière).";
    }
    return "Échec: $englishMessage";
  }
}