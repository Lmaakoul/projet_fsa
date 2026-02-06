import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ضروري لجلب التوكن
import '../model/prof_info_model.dart';

class ProfService {
  // ✅ يجب أن يطابق الرابط الموجود في AuthService
  final String baseUrl = "http://attendance-system.koyeb.app";
  // final String baseUrl = "http://192.168.43.106:8080"; // للشبكة المحلية

  // ==========================================================
  // 🔐 دالة مساعدة لجلب الـ Headers مع التوكن
  // ==========================================================
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token", // ✅ إرفاق التوكن
    };
  }

  // ==========================================================
  // 1. جلب بروفايل الأستاذ
  // ==========================================================
  Future<ProfInfoModel?> fetchProfProfile(int profId) async {
    // 🛑 تصحيح الآيدي إذا كان 0 (للتجربة)
    if (profId == 0) {
      print("⚠️ ProfId is 0, switching to 1 for testing.");
      profId = 1;
    }

    final url = Uri.parse('$baseUrl/api/professors/$profId'); // تأكد من وجود /api
    print("🔗 [GET] Connecting to: $url");

    try {
      final headers = await _getHeaders(); // ✅ جلب الهيدرز مع التوكن
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // دعم Pagination (content: [])
        if (data.containsKey('content') && (data['content'] as List).isNotEmpty) {
          return ProfInfoModel.fromJson(data['content'][0]);
        }
        // دعم الكائن المباشر
        else if (!data.containsKey('content')) {
          return ProfInfoModel.fromJson(data);
        }
        return null;
      } else {
        print("❌ Server Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      return null;
    }
  }

  // ==========================================================
  // 2. جلب الاسم (للـ Header)
  // ==========================================================
  Future<String> fetchProfFullName(int profId) async {
    try {
      final profModel = await fetchProfProfile(profId);
      if (profModel != null) {
        return profModel.fullName;
      }
      return "Professeur Inconnu";
    } catch (e) {
      return "Professeur";
    }
  }

  // ==========================================================
  // 3. التحقق من الطالب (SCAN)
  // ==========================================================
  Future<bool> verifyCneAndGroup({required String cne, required int groupId}) async {
    final url = Uri.parse('$baseUrl/api/students/verify');

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          "cne": cne,
          "groupId": groupId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is bool) return data;
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      print("❌ Scan Error: $e");
      return false;
    }
  }

  // ==========================================================
  // 4. جلب المواد (Modules)
  // ==========================================================
  Future<List<Map<String, dynamic>>> fetchModulesByProfAndParcours(int profId, int parcoursId) async {
    final url = Uri.parse('$baseUrl/api/professors/$profId/parcours/$parcoursId/modules');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      // بيانات وهمية في حالة الخطأ
      return [{'id': 101, 'nom': 'Java (Offline)'}];
    } catch (e) {
      return [{'id': 101, 'nom': 'Java (Error)'}];
    }
  }

  // دالة مساعدة أخيرة
  Future<Map<String, dynamic>> fetchProfessorDetails(int profId) async {
    final prof = await fetchProfProfile(profId);
    if (prof != null) {
      return {
        'prenom': prof.firstName,
        'nom': prof.lastName,
        'email': prof.email,
        'telephone': prof.phoneNumber,
        'grade': prof.grade,
        'departement': {'nom': prof.departmentName},
        'username': prof.username,
      };
    }
    return {};
  }
}