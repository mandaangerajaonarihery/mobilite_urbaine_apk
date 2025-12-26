// lib/services/vehicule_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:all_pnud/models/vehicule.dart';
import 'package:all_pnud/models/immatriculation_info.dart'; // <-- Importation du modèle
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:all_pnud/constantes/api.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
class VehiculeService {
  final String baseUrl = Api.baseUrl;

  Future<List<Vehicule>> getVehiculesByCitizenId(String? citizenId, String? token) async {
    if (citizenId == null || token == null) {
      debugPrint("❌ ID citoyen ou token manquant.");
      return [];
    }

    final url = Uri.parse("$baseUrl/vehicules/proprietaire/$citizenId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['data'] == null) {
          return [];
        }
        final List<dynamic> data = decoded['data'];
        return data.map((item) => Vehicule.fromJson(item)).toList();
      } else {
        debugPrint("❌ Erreur API: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Erreur réseau: $e");
      return [];
    }
  }

Future<bool> createVehiculeWithDocs({
  required Map<String, dynamic> vehiculeData,
  required List<http.MultipartFile> files, // liste déjà préparée
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) return false;

  final uri = Uri.parse("$baseUrl/vehicules/with-docs");
  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $token';

  // Champs texte
  vehiculeData.forEach((key, value) {
    if (value != null) request.fields[key] = value.toString();
  });

  // Ajouter les fichiers déjà préparés
  request.files.addAll(files);
 // 🟢 LOG des données envoyées
  debugPrint("===== 📤 DONNÉES FORM-DATA =====");
  request.fields.forEach((key, value) {
    debugPrint("Champ: $key = $value");
  });
  for (var f in request.files) {
    debugPrint("Fichier: ${f.field} -> ${f.filename} (${f.length} bytes)");
  }
  debugPrint("================================");

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint("🔴 Réponse API: ${response.statusCode} - ${response.body}");
    return response.statusCode == 201;
  } catch (e) {
    debugPrint("Erreur réseau: $e");
    return false;
  }
}

}
// lib/services/vehicule_service.dart


