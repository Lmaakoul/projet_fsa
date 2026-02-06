import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ 1. استيراد مودل البروفيسور من مكانه الصحيح (حسب صورتك)
import 'package:university_app/features/3_professor_role/prof/model/prof_info_model.dart';

// ✅ 2. استيراد مودل الأدمن (Professor)
import 'package:university_app/core/models/professor.dart';

class ProfessorService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  Future<Map<String, String>> _getHeaders({String? token}) async {
    String? authToken = token;
    if (authToken == null) {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('authToken');
    }
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (authToken != null) "Authorization": "Bearer $authToken",
    };
  }

  // ==========================================================
  // 🟢 PARTIE 1: ADMIN (CRUD)
  // ==========================================================
  Future<List<Professor>> getAllProfessors(String token) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/professors'), headers: await _getHeaders(token: token));
      return response.statusCode == 200 ? professorFromJson(response.body) : [];
    } catch (e) { return []; }
  }

  Future<bool> createProfessor({required String token, required String firstName, required String lastName, required String email, required String grade, required String departmentId, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/professors'),
        headers: await _getHeaders(token: token),
        body: jsonEncode({
          "firstName": firstName, "lastName": lastName, "email": email, "username": email,
          "grade": grade, "departmentId": departmentId, "password": password
        }),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> updateProfessor({required String token, required String id, required String firstName, required String lastName, required String email, required String grade, required String departmentId}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/professors/$id'),
        headers: await _getHeaders(token: token),
        body: jsonEncode({
          "firstName": firstName, "lastName": lastName, "email": email, "username": email,
          "grade": grade, "departmentId": departmentId
        }),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> deleteProfessor({required String token, required String professorId}) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/api/professors/$professorId'), headers: await _getHeaders(token: token));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { return false; }
  }

  // ==========================================================
  // 🔵 PARTIE 2: PROFESSOR (PROFILE & SCAN)
  // ==========================================================

  Future<ProfInfoModel?> fetchProfProfile(dynamic profId) async {
    final prefs = await SharedPreferences.getInstance();
    // محاولة استخدام الآيدي المخزن إذا لم يتم تمريره
    if (profId == null || profId == 0 || profId == "0") {
      profId = prefs.getString('userId');
      if (profId == null) {
        print("⚠️ ID null, utilisation de 1 par défaut");
        profId = 1;
      }
    }

    final url = Uri.parse('$_baseUrl/api/professors/$profId');
    print("🔗 [GET] Profile: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(utf8.decode(response.bodyBytes));

        // التعامل مع هيكلية البيانات المختلفة (Content List vs Object)
        if (data is Map<String, dynamic>) {
          if (data.containsKey('content') && (data['content'] as List).isNotEmpty) {
            return ProfInfoModel.fromJson(data['content'][0]);
          } else if (!data.containsKey('content')) {
            return ProfInfoModel.fromJson(data);
          }
        }
        return null;
      }
      print("❌ Error Fetch Profile: ${response.statusCode}");
      return null;
    } catch (e) {
      print("❌ Connection Error: $e");
      return null;
    }
  }

  Future<String> fetchProfFullName(dynamic profId) async {
    try {
      final prof = await fetchProfProfile(profId);
      return prof?.fullName ?? "Professeur";
    } catch (e) { return "Professeur"; }
  }

  Future<bool> verifyCneAndGroup({required String cne, required int groupId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/students/verify'),
        headers: await _getHeaders(),
        body: json.encode({"cne": cne, "groupId": groupId}),
      );
      if(response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] == true || data == true;
      }
      return false;
    } catch (e) { return false; }
  }

  Future<List<Map<String, dynamic>>> fetchModulesByProfAndParcours(int profId, int parcoursId) async {
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/api/professors/$profId/parcours/$parcoursId/modules'),
          headers: await _getHeaders()
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [{'id': 101, 'nom': 'Java (Offline)'}];
    } catch (e) { return [{'id': 101, 'nom': 'Error (Offline)'}]; }
  }
}