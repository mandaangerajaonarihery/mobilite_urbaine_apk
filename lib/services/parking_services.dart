import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:all_pnud/models/parking.dart';
import 'package:latlong2/latlong.dart';
import 'package:all_pnud/constantes/api.dart';
class ParkingService {
  static const String baseUrl = Api.baseUrl;

  /// Récupère la liste de tous les parkings avec pagination
  Future<List<Parking>> getParkings({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/parkings?page=$page&limit=$limit');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> parkingsJson = jsonResponse['data'];

        return parkingsJson.map((json) => Parking.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Échec du chargement des parkings. Code de statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  /// 🔹 Filtrer côté client par municipalityId
  Future<List<Parking>> getParkingsByMunicipality(
      String municipalityId, {int page = 1, int limit = 10}) async {
    final url = Uri.parse(
        '$baseUrl/parkings/municipality/$municipalityId?page=$page&limit=$limit');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('data')) {
        final List<dynamic> parkingsJson = jsonResponse['data'];
        return parkingsJson.map((json) => Parking.fromJson(json)).toList();
      } else {
        return [];
      }
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          'Erreur lors du chargement des parkings de la municipalité');
    }
  }
   Future<List<Parking>> getNearbyParkings(LatLng userLocation,
      {double radiusMeters = 500, int page = 1, int limit = 50}) async {
    final allParkings = await getParkings(page: page, limit: limit);
    final distance = Distance();

    return allParkings.where((parking) {
      if (parking.localisation.isEmpty) return false;

      // ⚡ On calcule le centroïde du premier polygone du parking
      final center = parking.localisation[0].fold<LatLng>(
        LatLng(0, 0),
        (prev, point) => LatLng(
          prev.latitude + point.latitude,
          prev.longitude + point.longitude,
        ),
      );
      final centroid = LatLng(
        center.latitude / parking.localisation[0].length,
        center.longitude / parking.localisation[0].length,
      );

      final d = distance(userLocation, centroid);
      return d <= radiusMeters;
    }).toList();
  }
}
