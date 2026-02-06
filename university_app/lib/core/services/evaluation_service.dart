import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/evaluation.dart';

class EvaluationService {
  final String _baseUrl = "https://fsa-ms-latest.onrender.com";

  // ---------------------------------------------------------------------------
  // 1. GET EVALUATIONS (Filter by Module & Group)
  // ---------------------------------------------------------------------------
  Future<List<Evaluation>> getEvaluations({
    required String token,
    required String moduleId,
    required String groupeId,
    String? type,
  }) async {
    // بناء الرابط مع الفلتر
    // ملاحظة: تأكد أن الباك إند يقبل studentGroupId، وإلا سنفلتر محلياً
    String query = 'moduleId=$moduleId&studentGroupId=$groupeId&page=0&size=100';

    if (type != null && type.isNotEmpty) {
      query += '&type=$type';
    }

    final url = Uri.parse('$_baseUrl/api/evaluations?$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return evaluationFromJson(response.body);
      } else {
        print("❌ Failed to load evaluations: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Evaluation Service Exception (GET): $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 2. CREATE EVALUATION (POST)
  // ---------------------------------------------------------------------------
  Future<bool> createEvaluation({
    required String token,
    required String studentId,
    required String moduleId,
    required String type,
    required double grade,
    required double maxGrade,
    required double coefficient,
    required String date,
    String comments = "",
  }) async {
    final url = Uri.parse('$_baseUrl/api/evaluations');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "studentId": studentId,
          "moduleId": moduleId,
          "type": type,
          "grade": grade,
          "maxGrade": maxGrade,
          "coefficient": coefficient,
          "date": date,
          "comments": comments,
          "isValidated": true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Evaluation Created Successfully");
        return true;
      } else {
        print("❌ Failed to create evaluation: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Evaluation Service Exception (POST): $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. UPDATE EVALUATION (PUT)
  // ---------------------------------------------------------------------------
  Future<bool> updateEvaluation({
    required String token,
    required String evaluationId,
    required String type,
    required double grade,
    required double coefficient,
    required String date,
  }) async {
    final url = Uri.parse('$_baseUrl/api/evaluations/$evaluationId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "type": type,
          "grade": grade,
          "coefficient": coefficient,
          "date": date,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Evaluation Updated Successfully");
        return true;
      } else {
        print("❌ Failed to update evaluation: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Evaluation Service Exception (PUT): $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. DELETE EVALUATION (DELETE)
  // ---------------------------------------------------------------------------
  Future<bool> deleteEvaluation(String token, String evaluationId) async {
    final url = Uri.parse('$_baseUrl/api/evaluations/$evaluationId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Evaluation Deleted Successfully");
        return true;
      } else {
        print("❌ Failed to delete evaluation: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Evaluation Service Exception (DELETE): $e");
      return false;
    }
  }
}