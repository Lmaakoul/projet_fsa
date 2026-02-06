import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/presence_percentage_dto.dart';
// import '../model/seance_stats.dart'; // Likely no longer needed if stats are per module

// ✅ Use the correct base URL (local or deployed)
const String _apiBaseUrl = "http://attendance-system.koyeb.app/api";
// const String _apiBaseUrl = "http://10.0.2.2:8080/api"; // For local Android emulator
// const String _apiBaseUrl = "http://localhost:8080/api"; // For local web/desktop

class PresenceService {
  final String _attendanceEndpoint = "$_apiBaseUrl/attendance"; // Changed base endpoint name

  // ✅ Updated to use the bulk endpoint
  /// 📤 Envoyer les données de présence (en bloc) à l’API
  Future<void> savePresenceData({
    required int profId,
    required String filiere, // Keep for context, maybe needed by backend?
    required String parcours, // Keep for context, maybe needed by backend?
    required String module, // Keep for context, maybe needed by backend?
    required String groupe, // Keep for context, maybe needed by backend?
    required String seance, // Keep for context, maybe needed by backend?
    required List<Map<String, dynamic>> students, // List of student statuses
  }) async {
    // ✅ Use the bulk endpoint from Swagger
    final url = Uri.parse('$_attendanceEndpoint/bulk');
    final headers = {'Content-Type': 'application/json'};

    // ⚠️ Adapt the body structure to match BulkAttendanceDto in Swagger
    // Assuming BulkAttendanceDto expects a list of objects, each containing studentId/cne, sessionId, status
    // You might need the actual session ID here instead of just the 'seance' string.
    // This is a GUESS - adjust based on your actual BulkAttendanceDto
    final List<Map<String, dynamic>> bulkData = students.map((student) {
      return {
        // You'll likely need IDs fetched earlier or passed down
        'studentId': student['id'], // Assuming student map has 'id'
        'sessionId': int.tryParse(seance.split(':')[0].replaceAll('Seance ', '')) ?? 0, // Example: Extract ID from "Seance 1: ..."
        'status': student['present'] == true ? 'PRESENT' : 'ABSENT', // Assuming backend uses these strings
        'isJustified': false, // Default justification status
        'isRattrapage': student['isRattrapage'] ?? false,
        // Add other fields required by BulkAttendanceDto
      };
    }).toList();

    // The main request body might need a specific structure too
    final body = jsonEncode({
      'attendanceRecords': bulkData,
      // Include profId, etc., only if the BulkAttendanceDto requires them directly
      // 'profId': profId,
      // 'moduleCode': module, // Example if needed
    });

    print("Sending Bulk Attendance Data: $body"); // For debugging

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("Save Presence Status: ${response.statusCode}"); // For debugging
      print("Save Presence Body: ${response.body}"); // For debugging

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'Erreur serveur';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Code: ${response.statusCode}';
        } catch(_) {
          errorMessage = 'Code: ${response.statusCode} - ${response.reasonPhrase}';
        }
        throw Exception("$errorMessage");
      } else {
        print('✅ Données de présence envoyées avec succès !');
      }
    } catch(e) {
      print("Error saving presence: $e");
      throw Exception("Erreur lors de l'envoi des données : $e");
    }
  }


  // ✅ Updated endpoint
  Future<PresencePercentageDto?> getStatsForGroupe(int groupeId) async { // Return nullable DTO
    // ✅ Use endpoint from Swagger
    final url = Uri.parse('$_attendanceEndpoint/statistics/group/$groupeId');
    print("Fetching group stats from: $url"); // Debugging

    try {
      final response = await http.get(url);
      print("Group Stats Status: ${response.statusCode}"); // Debugging
      print("Group Stats Body: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ⚠️ Adapt parsing based on the actual JSON response structure
        // Assuming the response directly contains percentage fields
        return PresencePercentageDto(
          presentPercentage: (data['presentPercentage'] as num?)?.toDouble() ?? 0.0,
          absentPercentage: (data['absentPercentage'] as num?)?.toDouble() ?? 0.0,
        );
      } else if (response.statusCode == 404) {
        print("No stats found for group ID: $groupeId");
        return null; // Return null if no stats found
      }
      else {
        throw Exception("Échec de la récupération des stats du groupe (Code: ${response.statusCode})");
      }
    } catch (e) {
      print("Error fetching group stats: $e");
      throw Exception("Erreur lors du chargement des stats du groupe: $e");
    }
  }

  // ⚠️ Function likely needs to be removed or adapted as endpoint doesn't match
  // Swagger provides stats per module ID, not broken down by seance within the module.
  /*
  Future<List<SeanceStats>> fetchSeancesStatsByModule(String moduleNom) async {
    // This endpoint `/stats/seance?moduleNom=` is not in Swagger.
    // The closest is `/stats/module/{moduleId}` which gives overall module stats.
    final url = "$baseUrl/stats/seance?moduleNom=$moduleNom"; // Original incorrect URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SeanceStats.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des statistiques par séance");
    }
  }
  */

  // ⚠️ Function commented out - No direct equivalent endpoint in Swagger
  /*
  Future<Map<String, double>> getGlobalStatsByParcours(String nomParcours) async {
    // No endpoint like `/stats/parcours?nom=` found in Swagger.
    final encodedNomParcours = Uri.encodeComponent(nomParcours);
    final url = "$baseUrl/stats/parcours?nom=$encodedNomParcours"; // Original incorrect URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {
        "present": (json['present'] as num).toDouble(),
        "absent": (json['absent'] as num).toDouble(),
      };
    } else {
      throw Exception("Erreur lors du chargement des stats par parcours");
    }
  }
  */

  // ⚠️ Function commented out - No direct equivalent endpoint in Swagger
  /*
   Future<PresencePercentageDto> getStatsForFiliere(String nomFiliere) async {
    // No endpoint like `/stats/filiere?nom=` found in Swagger.
    final encoded = Uri.encodeComponent(nomFiliere);
    final url = "$baseUrl/stats/filiere?nom=$encoded"; // Original incorrect URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PresencePercentageDto(
        presentPercentage: (json['present'] as num).toDouble(),
        absentPercentage: (json['absent'] as num).toDouble(),
      );
    } else {
      throw Exception("Erreur lors du chargement des stats par filière");
    }
  }
  */

  // ✅ Updated endpoint - Requires Module ID, not name
  Future<PresencePercentageDto?> getStatsForModule(int moduleId) async { // Return nullable DTO, accept int ID
    // ✅ Use endpoint from Swagger
    final url = Uri.parse("$_attendanceEndpoint/statistics/module/$moduleId");

    print("Fetching module stats from: $url"); // Debugging

    try {
      final response = await http.get(url);

      print("Module Stats Status (${response.statusCode}) : ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // ⚠️ Adapt parsing based on actual response structure
        return PresencePercentageDto(
          presentPercentage: (json['presentPercentage'] as num?)?.toDouble() ?? 0.0,
          absentPercentage: (json['absentPercentage'] as num?)?.toDouble() ?? 0.0,
        );
      } else if (response.statusCode == 404) {
        print("No stats found for module ID: $moduleId");
        return null; // Return null if no stats found
      }
      else {
        throw Exception("Erreur lors du chargement des stats du module (Code: ${response.statusCode})");
      }
    } catch (e) {
      print("Error fetching module stats: $e");
      throw Exception("Erreur lors du chargement des stats du module: $e");
    }
  }

} // End of class PresenceService