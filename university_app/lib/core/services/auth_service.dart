import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  final String baseUrl = ApiConstants.baseUrl;

  // ------------------------------------------------------------------
  // 💾 TOKEN & STORAGE MANAGEMENT (إدارة التوكن والذاكرة)
  // ------------------------------------------------------------------

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print("💾 AccessToken enregistré avec succès");
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // مسح جميع البيانات
  }

  // ------------------------------------------------------------------
  // 🔐 LOGIN & USER INFO (تسجيل الدخول وجلب المعلومات)
  // ------------------------------------------------------------------

  // --- 1. تسجيل الدخول (POST /api/auth/login) ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl${ApiConstants.loginEndpoint}");
    print("🔄 Connexion: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("📥 Status Code: ${response.statusCode}");

      // 🔥 هام جداً: طباعة الاستجابة الخام لكشف مشكلة الأدوار
      print("📦 RAW SERVER BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // 1. استخراج وحفظ التوكن
        String? token = data['accessToken'];
        if (token != null) {
          await _saveToken(token);
        } else {
          throw Exception("Erreur: accessToken manquant !");
        }

        // 2. استخراج وحفظ الآيدي
        String userId = data['userId']?.toString() ?? '';
        if (userId.isNotEmpty) {
          await prefs.setString('userId', userId);
        }

        // 3. استخراج وحفظ الدور
        String role = 'UNKNOWN';
        if (data['roles'] != null && (data['roles'] as List).isNotEmpty) {
          role = data['roles'][0].toString(); // أخذ الدور الأول
          await prefs.setString('userRole', role);
        } else {
          print("⚠️ تنبيه: قائمة الأدوار (roles) فارغة من السيرفر!");
        }

        print("✅ Login Success: ID=$userId, Role=$role");

        return {
          'id': userId,
          'role': role,
          'token': token
        };
      }

      throw Exception('Erreur Login (${response.statusCode})');
    } catch (e) {
      print("❌ Erreur Auth: $e");
      rethrow;
    }
  }

  // --- 2. جلب معلومات المستخدم (GET /api/auth/me) ---
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse("$baseUrl${ApiConstants.currentUserEndpoint}");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ------------------------------------------------------------------
  // 📝 REGISTRATION METHODS (دوال التسجيل المختلفة)
  // ------------------------------------------------------------------

  // --- 3. تسجيل طالب (POST) ---
  Future<bool> registerStudent({
    required String username, required String email, required String password,
    required String cne, required String cin, required String firstName,
    required String lastName, required String dateOfBirth, required String filiereId,
    required String phoneNumber, required String address,
  }) async {
    final url = Uri.parse("$baseUrl${ApiConstants.registerStudentEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, "email": email, "password": password,
          "cne": cne, "cin": cin, "firstName": firstName,
          "lastName": lastName, "dateOfBirth": dateOfBirth,
          "filiereId": filiereId, "phoneNumber": phoneNumber, "address": address,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      throw Exception('Erreur Student Registration (${response.statusCode})');
    } catch (e) {
      print("❌ Erreur Register Student: $e");
      rethrow;
    }
  }

  // --- 4. تسجيل أستاذ (POST) ---
  Future<bool> registerProfessor({
    required String username, required String email, required String password,
    required String firstName, required String lastName, required String grade,
    required String departmentId, required String phoneNumber,
    required String officeLocation, required String specialization,
  }) async {
    final url = Uri.parse("$baseUrl${ApiConstants.registerProfessorEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, "email": email, "password": password,
          "firstName": firstName, "lastName": lastName, "grade": grade,
          "departmentId": departmentId, "phoneNumber": phoneNumber,
          "officeLocation": officeLocation, "specialization": specialization,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      throw Exception('Erreur Professor Registration (${response.statusCode})');
    } catch (e) {
      print("❌ Erreur Register Professor: $e");
      rethrow;
    }
  }

  // --- 5. تسجيل مسؤول (POST) ---
  Future<bool> registerAdmin({
    required String username, required String email, required String password,
    required String firstName, required String lastName,
  }) async {
    final url = Uri.parse("$baseUrl${ApiConstants.registerAdminEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, "email": email, "password": password,
          "firstName": firstName, "lastName": lastName,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      throw Exception('Erreur Admin Registration (${response.statusCode})');
    } catch (e) {
      print("❌ Erreur Register Admin: $e");
      rethrow;
    }
  }

  // --- 6. تسجيل مسؤول خارق (POST) ---
  Future<bool> registerSuperAdmin({
    required String username, required String email, required String password,
    required String firstName, required String lastName,
  }) async {
    // تأكد أنك أضفت registerSuperAdminEndpoint في ApiConstants
    final url = Uri.parse("$baseUrl${ApiConstants.registerSuperAdminEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, "email": email, "password": password,
          "firstName": firstName, "lastName": lastName,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      throw Exception('Erreur Super Admin Registration (${response.statusCode})');
    } catch (e) {
      print("❌ Erreur Register Super Admin: $e");
      rethrow;
    }
  }

  // ------------------------------------------------------------------
  // 🔒 PASSWORD MANAGEMENT (إدارة كلمة المرور)
  // ------------------------------------------------------------------

  Future<bool> forgotPassword(String email) async {
    final url = Uri.parse("$baseUrl${ApiConstants.forgotPasswordEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      throw Exception('Erreur Forgot Password (${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    final url = Uri.parse("$baseUrl${ApiConstants.resetPasswordEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "newPassword": newPassword
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      throw Exception('Erreur Reset Password (${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  // دالة تغيير كلمة المرور للمستخدم المسجل دخوله
  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl${ApiConstants.changePasswordEndpoint}");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "currentPassword": currentPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}