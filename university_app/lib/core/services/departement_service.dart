// lib/core/services/departement_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/departement.dart';

class DepartementService {

  // -------------------------------------------------------------------
  // --- 1. GET ALL (جلب القائمة) ---
  // -------------------------------------------------------------------
  Future<List<Departement>> getAllDepartements(String token) async {
    // نضيف page=0&size=100 لجلب أكبر عدد ممكن من الأقسام دفعة واحدة
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.departmentsEndpoint}?page=0&size=100');

    print("🔄 GET ${url}");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // نستخدم دالة التحويل التي تأخذ بعين الاعتبار حقل 'content'
        return departementFromJson(response.body);
      } else {
        print("❌ Failed to load departements: ${response.statusCode}");
        print("Response body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Departement Service Exception (GET): $e");
      return [];
    }
  }

  // -------------------------------------------------------------------
  // --- 2. CREATE (POST) (إنشاء قسم جديد) ---
  // -------------------------------------------------------------------
  Future<bool> createDepartement({
    required String token,
    required String name,
    required String code,
    required String description,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.departmentsEndpoint);

    print("🔄 POST Creation: $url");

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
          "description": description,
        }),
      );

      print("📥 Status Code: ${response.statusCode}");

      // ✅ التصحيح المهم: قبول 200 (OK) و 201 (Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Departement Created Successfully");
        print("Response body: ${response.body}"); // للتأكد من البيانات
        return true;
      } else {
        print("❌ Failed to create departement: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Departement Service Exception (POST): $e");
      return false;
    }
  }

  // -------------------------------------------------------------------
  // --- 3. UPDATE (PUT) (تعديل قسم) ---
  // -------------------------------------------------------------------
  Future<bool> updateDepartement({
    required String token,
    required String id,
    required String name,
    required String code,
    required String description,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.departmentsEndpoint}/$id');

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
          "description": description,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Departement Updated Successfully");
        return true;
      } else {
        print("❌ Failed to update departement: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Departement Service Exception (PUT): $e");
      return false;
    }
  }

  // -------------------------------------------------------------------
  // --- 4. DELETE (حذف قسم) ---
  // -------------------------------------------------------------------
  Future<bool> deleteDepartement({
    required String token,
    required String departementId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.departmentsEndpoint}/$departementId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Departement Deleted Successfully");
        return true;
      } else {
        print("❌ Failed to delete departement: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Departement Service Exception (DELETE): $e");
      return false;
    }
  }
}