import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:all_pnud/models/chauffeur.dart';
import 'package:all_pnud/constantes/api.dart';
class ChauffeurService {
  final String baseUrl = '${Api.baseUrl}/chauffeurs';

  /// Récupérer tous les chauffeurs d'une municipalité
  Future<List<Chauffeur>> getChauffeursByMunicipality(int municipalityId) async {
    final url = Uri.parse('$baseUrl/municipality/$municipalityId');
    final response = await http.get(url, headers: {'accept': '*/*'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Chauffeur.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des chauffeurs');
    }
  }

  /// Récupérer un chauffeur via son CIN (dans une municipalité)
 /// Récupérer un chauffeur via son CIN (dans une municipalité)
Future<Chauffeur?> getChauffeurByCIN( String cinText) async {
  try {
    final url = Uri.parse('$baseUrl/search/cin/$cinText');
    final response = await http.get(url, headers: {'accept': 'application/json'});

    print("➡️ [API CALL] GET $url");
    print("⬅️ [RESPONSE CODE] ${response.statusCode}");
    print("⬅️ [RESPONSE BODY] ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final chauffeurData = data['chauffeur'];

      if (chauffeurData == null) return null;

      final chauffeur = Chauffeur.fromJson(chauffeurData);

      // Vérifier la municipalité pour rester cohérent avec l'ancienne logique
      // if (chauffeur.municipalityId != municipalityId.toString()) {
      //   print("⚠️ Chauffeur trouvé mais n'appartient pas à la municipalité demandée");
      //   return null;
      // }

      return chauffeur;
    } else if (response.statusCode == 404) {
      print("⚠️ Chauffeur non trouvé pour CIN: $cinText");
      return null;
    } else {
      print("❌ Erreur API (${response.statusCode}): ${response.body}");
      return null;
    }
  } catch (e) {
    print("❌ Exception lors de la récupération du chauffeur par CIN: $e");
    return null;
  }
}


  /// Créer un chauffeur (POST /chauffeurs)
  Future<Chauffeur?> createChauffeur({
    required String numPhone,
    required String email,
    required String municipalityId,
    required String citizenId,
    String? numPermis,
    String? categoriePermis,
    File? permisImage,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl');

    final request = http.MultipartRequest('POST', url);

    // Headers
    request.headers['accept'] = '*/*';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Champs requis
    request.fields['numPhon_chauffeur'] = numPhone;
    request.fields['email_chauffeur'] = email;
    request.fields['municipality_id'] = municipalityId;
    request.fields['cityzen_id'] = citizenId;

    // Champs optionnels
    if (numPermis != null) request.fields['numPermis_chauffeur'] = numPermis;
    if (categoriePermis != null) request.fields['categori_permis'] = categoriePermis;

    // Image optionnelle
    if (permisImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'permis_image',
        permisImage.path,
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final data = json.decode(responseBody);
      return Chauffeur.fromJson(data);
    } else {
      print('Erreur création chauffeur: ${response.statusCode} → $responseBody');
      return null;
    }
  }

   Future<List<Chauffeur>> getAllChauffeurs() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url, headers: {'accept': '*/*'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Chauffeur.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des chauffeurs');
    }
  }

  /// Vérifier si un chauffeur existe avec un idCitizen
  Future<Chauffeur?> getChauffeurByCitizenId(String citizenId) async {
    final chauffeurs = await getAllChauffeurs();
    try {
      return chauffeurs.firstWhere((c) => c.cityzenId == citizenId);
    } catch (e) {
      return null; // aucun chauffeur trouvé avec cet idCitizen
    }
  }Future<Map<String, dynamic>?> getChauffeurByCitizenIdEnriched(String citizenId) async {
  final url = Uri.parse('$baseUrl/cityzen/$citizenId');
  final response = await http.get(url, headers: {'accept': 'application/json'});

  // 🔍 Debug complet
  print("➡️ [API CALL] GET $url");
  print("⬅️ [RESPONSE CODE] ${response.statusCode}");
  print("⬅️ [RESPONSE BODY] ${response.body}");

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // 🔍 Debug des données extraites
    print("📦 [DATA] ${data['data']}");

    return data['data'];
  } else if (response.statusCode == 404) {
    print("⚠️ Chauffeur non trouvé pour citizenId: $citizenId");
    return null; // chauffeur non trouvé
  } else {
    print("❌ Erreur API (${response.statusCode}): ${response.body}");
    throw Exception('Erreur lors du chargement du chauffeur');
  }
}

}
