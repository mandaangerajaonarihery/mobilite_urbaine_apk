import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:all_pnud/constantes/api.dart';

class LocalisationService {
  static const String baseUrl = "${Api.Urlauth}/serviceterritoire-v2";

  /// 🔹 Trouve un arrondissement à partir de la latitude et longitude
  Future<Map<String, dynamic>?> findArrondissement({
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse(
      '$baseUrl/communes/find/by-location?lat=$lat&lng=$lng',
    );

    try {
      final response = await http
          .get(url, headers: {'accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // ✅ Reformater le formatted_id si présent
        if (jsonResponse.containsKey('formatted_id')) {
          jsonResponse['formatted_id'] =
              _formatFormattedId(jsonResponse['formatted_id']);
        }

        return jsonResponse;
      } else if (response.statusCode == 404) {
        print("❌ Aucun arrondissement trouvé pour cette position.");
        return null;
      } else {
        print("⚠️ Erreur serveur (${response.statusCode}) : ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Erreur réseau : $e");
      return null;
    }
  }

  /// Méthode privée pour reformater formatted_id si besoin
  String _formatFormattedId(String id) {
    // Exemple simple : supprimer les espaces superflus
    return id.trim();
  }
}
