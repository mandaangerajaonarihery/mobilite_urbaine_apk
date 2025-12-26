import 'dart:convert'; // pour jsonEncode et jsonDecode
import 'package:flutter/foundation.dart'; // pour debugPrint
import 'package:http/http.dart' as http; // pour http.get, http.put, etc.
import 'package:shared_preferences/shared_preferences.dart'; // pour SharedPreferences
import 'package:all_pnud/models/affectation.dart'; // ton modèle Affectation
import 'package:all_pnud/constantes/api.dart';
class AffectationService {
  final String baseUrl =Api.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint("❌ Token manquant. Impossible de faire la requête.");
    }
    return token;
  }

  Future<Map<String, String>?> _getHeaders() async {
    final token = await _getToken();
    if (token == null) return null;
    return {
      "Content-Type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<Affectation>> getAffectationsByCooperative(
      String cooperativeId) async {
    final headers = await _getHeaders();
    if (headers == null) return [];

    final url = Uri.parse("$baseUrl/affectations/cooperative/$cooperativeId");
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];
        return data.map((item) => Affectation.fromJson(item)).toList();
      } else {
        debugPrint("❌ Erreur API: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Erreur inattendue: $e");
      return [];
    }
  }

  Future<bool> validerAffectation(int affectationId) async {
    final headers = await _getHeaders();
    if (headers == null) return false;

    final url = Uri.parse("$baseUrl/affectations/$affectationId/valider");
    try {
      final response = await http.put(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Erreur validation affectation: $e");
      return false;
    }
  }

  Future<bool> rejeterAffectation(int affectationId) async {
    final headers = await _getHeaders();
    if (headers == null) return false;

    final url = Uri.parse("$baseUrl/affectations/$affectationId/rejeter");
    try {
      final response = await http.put(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Erreur rejet affectation: $e");
      return false;
    }
  }

  Future<bool> createAffectation({
    int? idChauffeur,
    required String immatriculation,
    required String idCooperative,
  }) async {
    final headers = await _getHeaders();
    if (headers == null) return false;

    final url = Uri.parse("$baseUrl/affectations");
    final bodyMap = {
      "immatriculation": immatriculation,
      "id_cooperative": idCooperative,
      if (idChauffeur != null) "id_chauffeur": idChauffeur,
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(bodyMap));
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Erreur création affectation: $e");
      return false;
    }
  }

  Future<bool> payerAffectation(int affectationId) async {
    final headers = await _getHeaders();
    if (headers == null) return false;

    // ⚠️ On enlève “/serviceflotte” car le endpoint Swagger indiqué était
    // https://gateway.tsirylab.com/affectations/{id_affectation}/payer
    // Si ton API est en réalité :
    // https://gateway.tsirylab.com/serviceflotte/affectations/{id_affectation}/payer
    // alors tu peux laisser "$baseUrl/affectations/$affectationId/payer".
    final url = Uri.parse("$baseUrl/affectations/$affectationId/payer");

    try {
      final response = await http.put(url, headers: headers);
      if (response.statusCode == 200) {
        debugPrint("✅ Affectation $affectationId payée avec succès");
        return true;
      } else {
        debugPrint("❌ Erreur API: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Erreur paiement affectation: $e");
      return false;
    }
  }
}
