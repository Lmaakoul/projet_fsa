import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salle.dart';

class SalleService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // 1. GET
  Future<List<Salle>> getAllSalles(String token) async {
    final url = Uri.parse('$_baseUrl/api/locations?page=0&size=1000');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return salleFromJson(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. CREATE (إصلاح الأسماء لتطابق Swagger)
  Future<bool> createSalle({
    required String token,
    required String roomNumber,
    required String building,
    required String roomType,     // ✅ كان type
    required int capacity,
    required String departmentId, // ✅ كان departmentName
  }) async {
    final url = Uri.parse('$_baseUrl/api/locations');
    try {
      // بناء الجسم حسب Swagger
      final body = {
        "roomNumber": roomNumber,
        "building": building,
        "roomType": roomType,
        "capacity": capacity,
        "departmentId": departmentId,
        "equipment": "Standard",
        "notes": "Added via App",
        "isActive": true
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. UPDATE (إصلاح الأسماء)
  Future<bool> updateSalle({
    required String token,
    required String salleId,
    required String roomNumber,
    required String building,
    required String roomType,     // ✅
    required int capacity,
    required String departmentId, // ✅
  }) async {
    final url = Uri.parse('$_baseUrl/api/locations/$salleId');
    try {
      final body = {
        "roomNumber": roomNumber,
        "building": building,
        "roomType": roomType,
        "capacity": capacity,
        "departmentId": departmentId,
        "isActive": true
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. DELETE
  Future<bool> deleteSalle({required String token, required String salleId}) async {
    final url = Uri.parse('$_baseUrl/api/locations/$salleId');
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}