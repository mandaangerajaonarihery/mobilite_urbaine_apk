// lib/services/affectation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:all_pnud/constantes/api.dart'; // Assure-toi que ce chemin est correct

class AffectationService {
  // L'URL de base pour ce service
  final String baseUrl = Api.baseUrl;

  /// Crée une affectation pour un véhicule qui n'est pas un bus (ex: Taxi, Bajaj).
  ///
  /// Prend en paramètre l'ID du chauffeur, l'immatriculation et le token d'authentification.
  /// Retourne `true` si la création réussit, `false` sinon.
  Future<bool> createAffectationNonBus({
    required int idChauffeur,
    required String immatriculation,
    required String token,
  }) async {
    // On construit l'URL complète de l'endpoint
    final url = Uri.parse('$baseUrl/affectationnonbus');

    // On prépare les headers de la requête
    final headers = {
      'Content-Type': 'application/json', // Indique qu'on envoie du JSON
      'Authorization': 'Bearer $token',    // Ajoute le token pour l'autorisation
    };

    // On prépare le corps de la requête
    final body = json.encode({
      'id_chauffeur': idChauffeur,
      'immatriculation': immatriculation,
    });

    print("➡️ [API CALL] POST $url");
    print("   - Body: $body");

    try {
      // On exécute la requête POST
      final response = await http.post(url, headers: headers, body: body);
      
      print("⬅️ [RESPONSE CODE] ${response.statusCode}");
      print("   - Response Body: ${response.body}");

      // On vérifie le code de statut de la réponse
      if (response.statusCode == 201) {
        // 201 Created : L'affectation a été créée avec succès.
        print("✅ Affectation (non-bus) créée avec succès.");
        return true;
      } else if (response.statusCode == 400) {
        // 400 Bad Request : Les données envoyées étaient invalides.
        print("⚠️ Données invalides pour la création de l'affectation.");
        return false;
      } else {
        // Gère les autres codes d'erreur (ex: 500 Erreur serveur)
        print("❌ Erreur inattendue lors de la création de l'affectation.");
        return false;
      }
    } catch (e) {
      // Gère les erreurs de réseau (pas de connexion, etc.)
      print("💥 Erreur réseau ou de parsing: $e");
      return false;
    }
  }
}