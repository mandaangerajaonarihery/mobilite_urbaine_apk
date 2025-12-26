import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

const String geoapifyApiKey = '71d43e78df2741edb6b0eb68f74a54d0';

Future<Map<String, dynamic>> getRouteGeoapify(LatLng start, LatLng end) async {
  final url =
      'https://api.geoapify.com/v1/routing?waypoints=${start.latitude},${start.longitude}|${end.latitude},${end.longitude}&mode=drive&apiKey=$geoapifyApiKey';

  final response = await http.get(Uri.parse(url));
  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    final features = jsonBody['features'] as List;
    if (features.isEmpty) {
      throw Exception("Aucun itinéraire trouvé");
    }
    final feature = features[0];
    final geometry = feature['geometry'];
    final properties = feature['properties'];

    var rawCoords = geometry['coordinates'];

    // MultiLineString: liste de liste de points
    List<LatLng> coords = [];
    if (geometry['type'] == 'MultiLineString') {
      for (var line in rawCoords) {
        for (var coord in line) {
          // Coordonnées au format [latitude, longitude] d'après ton JSON
          coords.add(LatLng(coord[1], coord[0]));
        }
      }
    } else if (geometry['type'] == 'LineString') {
      for (var coord in rawCoords) {
        coords.add(LatLng(coord[0], coord[1]));
      }
    } else {
      throw Exception("Type de géométrie non supporté: ${geometry['type']}");
    }

    // Conversion sécurisée en double
    final distanceRaw = properties['distance'] ?? 0;
    final distance = distanceRaw is int ? distanceRaw.toDouble() : distanceRaw;

    final durationRaw = properties['time'] ?? 0;
    final duration = durationRaw is int ? durationRaw.toDouble() : durationRaw;

    return {
      'coords': coords,
      'distance': distance,
      'duration': duration,
    };
  } else {
    print('Erreur Geoapify routing : ${response.statusCode} - ${response.body}');
    throw Exception('Impossible de récupérer le trajet');
  }
}
