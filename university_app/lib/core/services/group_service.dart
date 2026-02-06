import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group.dart';

class GroupService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // ---------------------------------------------------
  // 1. GET ALL GROUPS (لشاشة إدارة المجموعات)
  // ---------------------------------------------------
  Future<List<Group>> getAllGroups(String token) async {
    final url = Uri.parse('$_baseUrl/api/groups?page=0&size=1000'); // size كبير لضمان جلب الكل
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return groupFromJson(response.body);
      } else {
        print("❌ Failed to load groups: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Group Service Exception (GET ALL): $e");
      return [];
    }
  }

  // ---------------------------------------------------
  // 2. GET GROUPS BY MODULE ID (لشاشات الاختيار)
  // ---------------------------------------------------
  Future<List<Group>> getGroupsByModuleId(String token, String moduleId) async {
    final url = Uri.parse('$_baseUrl/api/groups/module/$moduleId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return groupFromJson(response.body);
      } else {
        print("❌ Failed to load groups by module: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Group Service Exception (GET BY MODULE): $e");
      return [];
    }
  }

  // ---------------------------------------------------
  // 3. CREATE GROUP (POST)
  // ---------------------------------------------------
  Future<bool> createGroup({
    required String token,
    required String name,
    required String code, // 🛑 حقل إلزامي في السيرفر
    required String moduleId,
    required int capacity,
  }) async {
    final url = Uri.parse('$_baseUrl/api/groups');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "code": code, // 🛑 إرسال الكود
          "moduleId": moduleId,
          "maxCapacity": capacity,
          "isActive": true
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Group Created Successfully");
        return true;
      } else {
        print("❌ Failed to create group: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Group Service Exception (POST): $e");
      return false;
    }
  }

  // ---------------------------------------------------
  // 4. UPDATE GROUP (PUT)
  // ---------------------------------------------------
  Future<bool> updateGroup({
    required String token,
    required String groupId,
    required String name,
    required String code, // 🛑 حقل إلزامي
    required String moduleId,
    required int capacity,
  }) async {
    final url = Uri.parse('$_baseUrl/api/groups/$groupId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "code": code, // 🛑 إرسال الكود
          "moduleId": moduleId,
          "maxCapacity": capacity,
          "isActive": true
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Group Updated Successfully");
        return true;
      } else {
        print("❌ Failed to update group: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Group Service Exception (PUT): $e");
      return false;
    }
  }

  // ---------------------------------------------------
  // 5. DELETE GROUP (DELETE)
  // ---------------------------------------------------
  Future<bool> deleteGroup({
    required String token,
    required String groupId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/groups/$groupId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Group Deleted Successfully");
        return true;
      } else {
        print("❌ Failed to delete group: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Group Service Exception (DELETE): $e");
      return false;
    }
  }

  // ---------------------------------------------------
  // 6. ENROLL STUDENTS
  // ---------------------------------------------------
  Future<bool> enrollStudentsInGroup(String token, String groupId, List<String> studentIds) async {
    final url = Uri.parse('$_baseUrl/api/groups/$groupId/enroll');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(studentIds),
      );

      if (response.statusCode == 200) {
        print("✅ Students Enrolled Successfully");
        return true;
      } else {
        print("❌ Failed to enroll students: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Group Service Exception (Enroll): $e");
      return false;
    }
  }
}