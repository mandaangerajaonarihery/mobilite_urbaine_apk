import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NavigationService {
  // Utilisons OSRM (Open Source Routing Machine) qui est gratuit et donne les instructions
  final String baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<Map<String, dynamic>> getRouteWithInstructions(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?steps=true&overview=full&geometries=geojson&language=fr'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 1. Récupérer les coordonnées pour le tracé bleu
        final geometry = data['routes'][0]['geometry']['coordinates'] as List;
        final List<LatLng> polyline = geometry
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();

        // 2. Récupérer les instructions (Turn by Turn)
        // L'API renvoie des "legs" qui contiennent des "steps"
        final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
        final List<Map<String, dynamic>> instructions = steps.map((step) {
          return {
            'instruction': step['maneuver']['instruction'], // Ex: "Tournez à droite"
            'distance': step['distance'], // Distance avant cette manœuvre
            'location': LatLng(step['maneuver']['location'][1], step['maneuver']['location'][0]),
          };
        }).toList();

        return {
          'polyline': polyline,
          'instructions': instructions,
          'duration': data['routes'][0]['duration'],
          'distance': data['routes'][0]['distance'],
        };
      }
    } catch (e) {
      print("Erreur routing: $e");
    }
    return {};
  }
}