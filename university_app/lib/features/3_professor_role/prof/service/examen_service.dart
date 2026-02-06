import 'dart:convert';
import 'package:http/http.dart' as http;

class ExamenService {
  // Base URL de ton backend
  final String baseUrl = 'http://192.168.43.106:8080/api/exams';

  // Méthode principale : récupère les deux listes (autorisés + exclus) via /validation?nomModule=X
  Future<Map<String, dynamic>> getValidationExamen(String nomModule) async {
    final url = Uri.parse('$baseUrl/validation?nomModule=$nomModule');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final autorises = jsonBody['autorises'] ?? [];
      final exclus = jsonBody['exclus'] ?? [];

      return {
        'success': true,
        'autorises': autorises,
        'exclus': exclus,
      };
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      final jsonBody = json.decode(response.body);
      return {
        'success': false,
        'error': jsonBody['erreur'] ?? 'Erreur inconnue',
      };
    } else {
      return {
        'success': false,
        'error': 'Erreur serveur - Code : ${response.statusCode}',
      };
    }
  }

  // Récupère uniquement la liste des étudiants autorisés
  Future<Map<String, dynamic>> getEtudiantsAutorises(String nomModule) {
    return _fetchList('autorises', nomModule);
  }

  // Récupère uniquement la liste des étudiants non autorisés
  Future<Map<String, dynamic>> getEtudiantsNonAutorises(String nomModule) {
    return _fetchList('non-autorises', nomModule);
  }

  // Fonction privée pour appeler l'API et parser la réponse
  Future<Map<String, dynamic>> _fetchList(String endpoint, String nomModule) async {
    final url = Uri.parse('$baseUrl/$endpoint?nomModule=$nomModule');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'data': data};
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      final error = json.decode(response.body);
      return {'success': false, 'error': error['erreur']};
    } else {
      return {'success': false, 'error': 'Erreur serveur - Code : ${response.statusCode}'};
    }
  }
}