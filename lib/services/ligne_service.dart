import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:all_pnud/models/ligne.dart';
import 'package:latlong2/latlong.dart';
import 'package:all_pnud/constantes/api.dart';

class LigneService {
  static const String baseUrl = Api.baseUrl;

  Future<List<Ligne>> getLignesByMunicipality(String municipalityId) async {
    final url = Uri.parse('$baseUrl/lignes/municipality/$municipalityId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> lignesJson = json.decode(response.body);

      final List<Ligne> lignes =
          lignesJson.map((json) => Ligne.fromJson(json)).toList();
      return lignes;
    } else if (response.statusCode == 404) {
      // Pas de lignes trouvées
      return [];
    } else {
      throw Exception(
          'Erreur lors du chargement des lignes pour la municipalité');
    }
  }

  /// Fetches a list of Lignes from a remote API with pagination.
  Future<List<Ligne>> getLignes({int page = 1, int limit = 10}) async {
    final uri = Uri.parse('$baseUrl/lignes?page=$page&limit=$limit');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> lignesJson = jsonResponse['data'];

        // This is where you would filter by cooperativeId if needed,
        // but the API endpoint seems to list all lines.
        // For a more specific request, you would need an endpoint like `/lignes/byCooperativeId`.

        final List<Ligne> lignes =
            lignesJson.map((json) => Ligne.fromJson(json)).toList();
        return lignes;
      } else {
        throw Exception(
            'Failed to load lines. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<List<Ligne>> getLignesByCooperative(String cooperativeId,
      {int page = 1, int limit = 10}) async {
    final url = Uri.parse(
      '$baseUrl/lignes/cooperative/$cooperativeId?page=$page&limit=$limit',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Ici on récupère la vraie liste des lignes
      if (body is Map && body['data'] is List) {
        return (body['data'] as List)
            .map((json) => Ligne.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Erreur lors du chargement des lignes');
    }
  }

  Future<LatLng?> searchPlace(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }
}
