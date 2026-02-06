import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Ensure you have this import
import '../models/seance.dart';

class SeanceService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // --- GET ---
  Future<List<Seance>> getSeances({required String token, String? moduleId, String? groupId}) async {
    String query = 'page=0&size=100';
    if (moduleId != null) query += '&moduleId=$moduleId';
    // Swagger endpoint is /api/sessions
    final url = Uri.parse('$_baseUrl/api/sessions?$query');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return seanceFromJson(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- CREATE (Fixing the 500 Error) ---
  Future<bool> createSeance({
    required String token,
    required String date,       // YYYY-MM-DD
    required String startTime,  // HH:mm
    required String endTime,    // HH:mm
    required String type,       // LECTURE, TP...
    required String salleId,
    required String moduleId,
    required String groupId,
    required String professorId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/sessions');

    try {
      // 1. Combine Date + StartTime to get "schedule" (ISO format)
      // Format: 2025-12-15T08:30:00
      DateTime startDateTime = DateTime.parse("$date $startTime:00");
      DateTime endDateTime = DateTime.parse("$date $endTime:00");

      // 2. Calculate "duration" in minutes
      int durationMinutes = endDateTime.difference(startDateTime).inMinutes;

      // 3. Prepare JSON exactly like Swagger
      final bodyData = {
        "name": "Seance $type",
        "type": type, // LECTURE, TP, TD...
        "moduleId": moduleId,
        "professorId": professorId,
        "locationId": salleId, // This is the Room ID
        "groupIds": [groupId], // Array of IDs
        "schedule": startDateTime.toIso8601String(), // ✅ CORRECT KEY
        "duration": durationMinutes,                 // ✅ CORRECT KEY
        "attendanceMode": "MANUAL",
        "isCompleted": false,
        "attendanceTaken": false
      };

      print("📤 Sending Seance: ${jsonEncode(bodyData)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Seance Created!");
        return true;
      } else {
        print("❌ Failed (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }

  // --- DELETE ---
  Future<bool> deleteSeance({required String token, required String seanceId}) async {
    final url = Uri.parse('$_baseUrl/api/sessions/$seanceId');
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}