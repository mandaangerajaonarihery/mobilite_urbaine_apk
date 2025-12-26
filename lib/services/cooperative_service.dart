// Fichier: lib/services/cooperative_service.dart
// Fichier : lib/services/cooperative_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_pnud/constantes/api.dart';
import 'package:all_pnud/models/cooperative.dart';
import 'package:all_pnud/models/affectation.dart';

/// 🔹 Service principal pour les coopératives
class CooperativeService {
  final String baseUrl = Api.baseUrl;

  Map<String, String> get _baseHeaders => {
        "Content-Type": "application/json",
        "accept": "application/json",
      };

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint("❌ Token manquant. Impossible de faire la requête.");
    }
    return token;
  }

  Future<void> clearCooperativeCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cooperative_data');
    debugPrint("🗑️ Cache de la coopérative effacé.");
  }

  // Future<Cooperative?> getCooperativeByCitizenId(String citizenId) async {
  //   final token = await _getToken();
  //   if (token == null) return null;

  //   final url = Uri.parse("$baseUrl/cooperatives/citizen/$citizenId");
  //   final headers = {..._baseHeaders, "Authorization": "Bearer $token"};

  //   try {
  //     final response = await http.get(url, headers: headers);
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       return Cooperative.fromJson(decoded['data']);
  //     } else if (response.statusCode == 404) {
  //       debugPrint("⚠️ Aucune coopérative trouvée pour ce citoyen.");
  //       return null;
  //     } else {
  //       debugPrint("❌ Erreur API: ${response.statusCode} - ${response.body}");
  //       return null;
  //     }
  //   } on http.ClientException {
  //     debugPrint("❌ Erreur réseau: Problème avec la connexion au serveur.");
  //     return null;
  //   } catch (e) {
  //     debugPrint("❌ Erreur inattendue: $e");
  //     return null;
  //   }
  // }
  Future<Cooperative?> getCooperativeByCitizenId(String citizenId) async {
    final token = await _getToken();
    if (token == null) return null;

    final urlSpecific = Uri.parse("$baseUrl/cooperatives/citizen/$citizenId");
    final headers = {..._baseHeaders, "Authorization": "Bearer $token"};

    try {
      final response = await http.get(urlSpecific, headers: headers);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['data'] != null) {
          return Cooperative.fromJson(decoded['data']);
        } else {
          debugPrint("⚠️ Endpoint spécifique renvoie null, fallback activé.");
        }
      } else if (response.statusCode == 404) {
        debugPrint("⚠️ Aucune coopérative trouvée via endpoint spécifique.");
      } else {
        debugPrint(
            "❌ Erreur API spécifique: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Erreur inattendue sur endpoint spécifique: $e");
    }

    //Fallback : récupère toutes les coopératives
    final urlAll = Uri.parse("$baseUrl/cooperatives");
    try {
      final responseAll = await http.get(urlAll, headers: headers);
      if (responseAll.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(responseAll.body);
        final coopJson = decodedList.firstWhere(
          (c) => c['id_citizen'] == citizenId,
          orElse: () => null,
        );
        if (coopJson != null) {
          return Cooperative.fromJson(coopJson);
        } else {
          debugPrint(
              "⚠️ Aucune coopérative trouvée pour le citizenId $citizenId.");
          return null;
        }
      } else {
        debugPrint("❌ Erreur API sur /cooperatives: ${responseAll.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Erreur inattendue sur /cooperatives: $e");
      return null;
    }
  }

  /// Récupère toutes les coopératives
  Future<List<Cooperative>> getAllCooperatives() async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/cooperatives");
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Cooperative.fromJson(json)).toList();
      } else {
        debugPrint(
            "❌ Erreur API /cooperatives: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint(
          "❌ Erreur réseau lors de la récupération des coopératives: $e");
      return [];
    }
  }

  Future<List<Cooperative>> getCooperativesByMunicipality(
      int municipalityId) async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/cooperatives/municipality/$municipalityId");
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Cooperative.fromJson(json)).toList();
      } else {
        debugPrint(
            "❌ Erreur API /cooperatives/municipality: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint(
          "❌ Erreur réseau lors de la récupération des coopératives: $e");
      return [];
    }
  }

  Future<List<Cooperative>> getCooperativesByStatus(
      String status, int municipalityId) async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse(
        "$baseUrl/cooperatives/status/$status/municipality/$municipalityId");
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Cooperative.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        debugPrint(
            "⚠️ Aucune coopérative trouvée pour status=$status et municipalityId=$municipalityId.");
        return [];
      } else {
        debugPrint(
            "❌ Erreur API /cooperatives/status: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint(
          "❌ Erreur réseau lors de la récupération des coopératives filtrées: $e");
      return [];
    }
  }

  Future<bool> registerCooperative({
    required String name,
    required int typeTransportId,
    required String siege,
    required String slogan,
    required String dateCreation,
    required String citizenId,
    required int municipalityId,
    required String nif,
    required String state,
    required String numCnaps,
    required double droitAdhesion,
    required XFile? regleInterneFile,
    required XFile? patenteFile,
    required XFile? accordMinFile,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final uri = Uri.parse("$baseUrl/cooperatives");
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    debugPrint("--- Données textuelles envoyées à l'API ---");
    debugPrint("name_cooperative: $name");
    debugPrint("typeTransport_id: $typeTransportId");
    debugPrint("siege_cooperative: $siege");
    debugPrint("slogant_cooperative: $slogan");
    debugPrint("dateCreation_cooperative: $dateCreation");
    debugPrint("id_citizen: $citizenId");
    debugPrint("municipality_id: $municipalityId");
    debugPrint("nif: $nif");
    debugPrint("num_cnaps: $numCnaps");
    debugPrint("state: $state");
    debugPrint("droit_adhesion: $droitAdhesion");

    debugPrint("------------------------------------------");

    request.fields.addAll({
      'name_cooperative': name,
      'typeTransport_id': typeTransportId.toString(),
      'siege_cooperative': siege,
      'slogant_cooperative': slogan,
      'dateCreation_cooperative': dateCreation,
      'id_citizen': citizenId,
      'municipality_id': municipalityId.toString(),
      'nif': nif,
      'state': state,
      'num_cnaps': numCnaps,
      'droit_adhesion': droitAdhesion.toString(),
    });

    Future<void> addFileToRequest(String fieldName, XFile? file) async {
      if (file != null) {
        // Correction ici : assigner un nom par défaut si file.name est vide
        String fileName = file.name.isNotEmpty ? file.name : '$fieldName.file';
        debugPrint(
            "Fichier ajouté : champ='$fieldName', nom='$fileName', taille=${await file.length()} octets");
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            await file.readAsBytes(),
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else {
        debugPrint("⚠️ Fichier manquant pour le champ $fieldName");
      }
    }

    debugPrint("--- Fichiers ajoutés à la requête ---");
    await addFileToRequest('regle_interne', regleInterneFile);
    await addFileToRequest('patente', patenteFile);
    await addFileToRequest('accord_min', accordMinFile);
    debugPrint("------------------------------------------");

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint("Réponse de l'API: ${response.statusCode} - ${response.body}");
      return response.statusCode == 201 || response.statusCode == 200;
    } on http.ClientException {
      debugPrint("❌ Erreur HTTP lors de l'envoi du formulaire.");
      return false;
    } catch (e) {
      debugPrint("❌ Erreur inattendue lors de l'enregistrement: $e");
      return false;
    }
  }
}

// ... (le reste du code est inchangé)

/// 🔹 Modèle du type de transport
class TransportType {
  final int id;
  final String name;

  TransportType({required this.id, required this.name});

  factory TransportType.fromJson(Map<String, dynamic> json) {
    return TransportType(
      id: json['id'],
      name: json['nom'] ?? "Inconnu",
    );
  }
}

/// 🔹 Service pour récupérer les types de transport
class TransportTypeService {
  final String baseUrl =Api.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint("❌ Token manquant. Impossible de faire la requête.");
    }
    return token;
  }

  Future<List<TransportType>> getTransportTypesByMunicipality(
      int municipalityId) async {
    final token = await _getToken();
    if (token == null) return [];

    final url =
        Uri.parse("$baseUrl/typetransports/municipality/$municipalityId");
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((e) => TransportType.fromJson(e)).toList();
      } else {
        debugPrint("❌ Erreur API: ${response.statusCode} - ${response.body}");
        return [];
      }
    } on http.ClientException {
      debugPrint("❌ Erreur réseau: Vérifiez votre connexion Internet.");
      return [];
    } catch (e) {
      debugPrint("❌ Erreur inattendue: $e");
      return [];
    }
  }
}
