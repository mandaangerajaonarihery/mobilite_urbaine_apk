import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Stop {
  final int id;
  final String name;
  final LatLng coordinates;
  final List<String> ligneId;

  Stop({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.ligneId,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as List<dynamic>;
    return Stop(
      id: json['id'],
      name: json['name'],
      coordinates: LatLng(coords[0], coords[1]),
      ligneId: List<String>.from(json['ligneId']),
    );
  }
}

class StopService {
  static const String baseUrl = "https://gateway.agvm.mg/serviceflotte";

  Future<List<Stop>> getStopsByMunicipality(String municipalityId) async {
    final url = Uri.parse('$baseUrl/stops/municipality/$municipalityId');
    final response = await http.get(url, headers: {"accept": "application/json"});

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Stop.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // Aucun arrêt trouvé
    } else {
      throw Exception("Erreur serveur: ${response.statusCode}");
    }
  }
}
