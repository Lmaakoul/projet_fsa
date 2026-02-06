// ملف: lib/core/services/module_service.dart
// (النسخة النهائية - CRUD كامل مع size=1000)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/module.dart';

class ModuleService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // --- 1. GET ALL (Updated size to 1000) ---
  Future<List<Module>> getAllModules(String token) async {
    // 🛑 قمنا بتغيير size من 100 إلى 1000 لضمان جلب كل البيانات
    final url = Uri.parse('$_baseUrl/api/modules?page=0&size=1000');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return moduleFromJson(response.body);
      } else {
        print("❌ Failed to load modules: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Module Service Exception (GET): $e");
      return [];
    }
  }

  // --- 2. CREATE (POST) ---
  Future<bool> createModule({
    required String token,
    required String title,
    required String code,
    required String semesterId,
    required int credits,
    required double passingGrade,
    required List<String> professorIds,
  }) async {
    final url = Uri.parse('$_baseUrl/api/modules');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "title": title,
          "code": code,
          "semesterId": semesterId,
          "credits": credits,
          "passingGrade": passingGrade,
          "professorIds": professorIds,
          "isActive": true,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Module Created Successfully");
        return true;
      } else {
        print("❌ Failed to create module: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Module Service Exception (POST): $e");
      return false;
    }
  }

  // --- 3. UPDATE (PUT) ---
  Future<bool> updateModule({
    required String token,
    required String id,
    required String title,
    required String code,
    required String semesterId,
    required int credits,
    required double passingGrade,
    required List<String> professorIds,
  }) async {
    final url = Uri.parse('$_baseUrl/api/modules/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "title": title,
          "code": code,
          "semesterId": semesterId,
          "credits": credits,
          "passingGrade": passingGrade,
          "professorIds": professorIds,
          "isActive": true,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Module Updated Successfully");
        return true;
      } else {
        print("❌ Failed to update module: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Module Service Exception (PUT): $e");
      return false;
    }
  }

  // --- 4. DELETE ---
  Future<bool> deleteModule({
    required String token,
    required String moduleId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/modules/$moduleId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Module Deleted Successfully");
        return true;
      } else {
        print("❌ Failed to delete module: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Module Service Exception (DELETE): $e");
      return false;
    }
  }
}