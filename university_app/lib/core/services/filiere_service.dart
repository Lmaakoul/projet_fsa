// ملف: lib/core/services/filiere_service.dart
// (النسخة النهائية والمكتملة لجميع الدوال المطلوبة)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filiere.dart'; // تأكد من أن هذا المسار صحيح

class FiliereService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // ---------------------------------------------------
  // 1. GET ALL (للتصفية المحلية في AddSemestreScreen)
  // ---------------------------------------------------
  Future<List<Filiere>> getAllFilieres(String token) async {
    final url = Uri.parse('$_baseUrl/api/filieres?page=0&size=100');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // نستخدم filiereFromJson لتحويل الاستجابة إلى قائمة Filieres
        return filiereFromJson(response.body);
      } else {
        print("❌ Failed to load all filieres: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Filiere Service Exception (GET ALL): $e");
      return [];
    }
  }

  // -------------------------------------------------------------
  // 2. GET BY DEGREE TYPE (للاستخدام الأمثل مع API)
  // -------------------------------------------------------------
  Future<List<Filiere>> getFilieresByDegreeType({
    required String token,
    required String degreeType,
    int page = 0,
    int size = 10,
    String sortBy = 'name',
    String sortDir = 'ASC',
  }) async {
    final path = '/api/filieres/degree-type/$degreeType';
    final url = Uri.parse('$_baseUrl$path').replace(queryParameters: {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    });

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return filiereFromJson(response.body);
      } else {
        print("❌ Failed to load filieres by degree type: Status ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Filiere Service Exception (GET BY DEGREE TYPE): $e");
      return [];
    }
  }

  // ---------------------------------------------------
  // 3. CREATE (POST)
  // ---------------------------------------------------
  Future<bool> createFiliere({
    required String token,
    required String name,
    required String code,
    required String degreeType,
    required String departmentId,
    required int durationYears,
  }) async {
    final url = Uri.parse('$_baseUrl/api/filieres');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "code": code,
          "degreeType": degreeType,
          "departmentId": departmentId,
          "durationYears": durationYears,
          "isActive": true,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Filiere Created Successfully");
        return true;
      } else {
        print("❌ Failed to create filiere: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Filiere Service Exception (CREATE): $e");
      return false;
    }
  }

  // ---------------------------------------------------
  // 4. UPDATE (PUT)
  // ---------------------------------------------------
  Future<bool> updateFiliere({
    required String token,
    required String id,
    required String name,
    required String code,
    required String degreeType,
    required String departmentId,
    required int durationYears,
  }) async {
    final url = Uri.parse('$_baseUrl/api/filieres/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "code": code,
          "degreeType": degreeType,
          "departmentId": departmentId,
          "durationYears": durationYears,
          "isActive": true,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Filiere Updated Successfully");
        return true;
      } else {
        print("❌ Failed to update filiere: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Filiere Service Exception (UPDATE): $e");
      return false;
    }
  }

  // ---------------------------------------------------
  // 5. DELETE
  // ---------------------------------------------------
  Future<bool> deleteFiliere({
    required String token,
    required String filiereId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/filieres/$filiereId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Filiere Deleted Successfully");
        return true;
      } else {
        print("❌ Failed to delete filiere: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Filiere Service Exception (DELETE): $e");
      return false;
    }
  }
}