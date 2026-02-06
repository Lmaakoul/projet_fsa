import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:university_app/core/models/student.dart';

// ✅ كلاس مساعدة بسيط لتمثيل المجموعات في القوائم المنسدلة
class GroupSimple {
  final String id;
  final String name;
  GroupSimple({required this.id, required this.name});

  factory GroupSimple.fromJson(Map<String, dynamic> json) {
    return GroupSimple(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Group',
    );
  }
}

class StudentService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // ===========================================================================
  // 1. GET FULL STUDENT DETAILS (جلب تفاصيل الطالب كاملة)
  // ✅ هذا هو الحل لمشكلة الحقول الفارغة في صفحة التعديل
  // ===========================================================================
  Future<Student?> getStudentById(String token, String studentId) async {
    final url = Uri.parse('$_baseUrl/api/students/$studentId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // فك التشفير لدعم الحروف الخاصة
        final jsonString = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(jsonString);
        return Student.fromJson(jsonData);
      } else {
        print("❌ Failed to load student details: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error (GET BY ID): $e");
      return null;
    }
  }

  // ===========================================================================
  // 2. GET STUDENTS BY GROUP (Workaround for Error 500)
  // ✅ نستخدم رابط المجموعة لجلب قائمة الطلاب لأن رابط الطلاب المباشر معطل
  // ===========================================================================
  Future<List<Student>> getStudentsByGroup(String token, String groupId) async {
    final url = Uri.parse('$_baseUrl/api/groups/$groupId');
    print("🔥🔥 Fetching Group Details (Workaround): $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        String jsonString = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(jsonString);

        // استخراج قائمة الطلاب من داخل كائن المجموعة
        final List<dynamic> studentsList = jsonResponse['students'] ?? [];

        return studentsList.map((json) => Student.fromJson(json)).toList();
      } else {
        print('❌ Server Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching students: $e');
      return [];
    }
  }

  // ===========================================================================
  // 3. GET GROUPS BY FILIERE (جلب المجموعات حسب الشعبة)
  // ✅ تستخدم في القائمة المنسدلة في صفحة التعديل والإضافة
  // ===========================================================================
  Future<List<GroupSimple>> getGroupsByFiliere(String token, String filiereId) async {
    final url = Uri.parse('$_baseUrl/api/groups/filiere/$filiereId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        String jsonString = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(jsonString);

        // التعامل مع احتمال أن السيرفر يرجع PageResponse أو List مباشرة
        final List<dynamic> content = jsonData is Map ? (jsonData['content'] ?? []) : jsonData;

        return content.map((e) => GroupSimple.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error fetching groups: $e");
      return [];
    }
  }

  // ===========================================================================
  // 4. CREATE STUDENT (إضافة طالب جديد)
  // ===========================================================================
  Future<String?> createStudent({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String cne,
    required String cin,
    required String dateOfBirth,
    required String filiereId,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/students');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "username": email,
          "cne": cne,
          "cin": cin,
          "dateOfBirth": dateOfBirth,
          "filiereId": filiereId,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['id'].toString();
      } else {
        print("❌ Create Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error (CREATE): $e");
      return null;
    }
  }

  // ===========================================================================
  // 5. UPDATE STUDENT (تحديث شامل: بيانات + مجموعة)
  // ===========================================================================
  Future<bool> updateStudent({
    required String token,
    required String studentId,
    required String firstName,
    required String lastName,
    required String email,
    required String cne,
    required String cin,
    required String dateOfBirth,
    required String filiereId,
    String? groupId, // ✅ معامل اختياري لتحديث المجموعة
  }) async {
    final url = Uri.parse('$_baseUrl/api/students/$studentId');
    try {
      // 1. تحديث البيانات الشخصية والأكاديمية
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "username": email,
          "cne": cne,
          "cin": cin,
          "dateOfBirth": dateOfBirth,
          "filiereId": filiereId,
        }),
      );

      if (response.statusCode != 200) {
        print("❌ Update Info Failed: ${response.body}");
        return false;
      }

      // 2. تحديث المجموعة (إذا تم اختيار مجموعة جديدة)
      if (groupId != null && groupId.isNotEmpty) {
        print("🔄 Updating Student Group to: $groupId");
        final enrollSuccess = await assignStudentToGroup(
            token: token,
            studentId: studentId,
            groupId: groupId
        );
        if (!enrollSuccess) print("⚠️ Group update failed, but profile updated.");
      }

      return true;
    } catch (e) {
      print("❌ Error (UPDATE): $e");
      return false;
    }
  }

  // ===========================================================================
  // 6. ASSIGN TO GROUP (تسجيل الطالب في مجموعة)
  // ===========================================================================
  Future<bool> assignStudentToGroup({
    required String token,
    required String studentId,
    required String groupId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/groups/$groupId/enroll');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "groupId": groupId,
          "studentIds": [studentId]
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error (ASSIGN): $e");
      return false;
    }
  }

  // ===========================================================================
  // 7. DELETE STUDENT (حذف طالب)
  // ===========================================================================
  Future<bool> deleteStudent({
    required String token,
    required String studentId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/students/$studentId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error (DELETE): $e");
      return false;
    }
  }
}