import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'Cooperative.dart';
import 'Stop.dart';

class Ligne {
  final int id;
  final String nom;
  final String municipalityId;
  final String couleur;
  final List<List<double>> trace;
  final int cooperativeId;
  final String createdAt;
  final String updatedAt;
  final Cooperative cooperative;
  final List<Stop> stops;

  Ligne({
    required this.id,
    required this.nom,
    required this.municipalityId,
    required this.couleur,
    required this.trace,
    required this.cooperativeId,
    required this.createdAt,
    required this.updatedAt,
    required this.cooperative,
    required this.stops,
  });

  factory Ligne.fromJson(Map<String, dynamic> json) {
    return Ligne(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      municipalityId: json['municipality_id'] ?? '',
      couleur: json['couleur'] ?? '#000000',
      trace: (json['tracé'] != null)
          ? List<List<double>>.from(
              (json['tracé'] as List).map(
                (x) => List<double>.from(
                  (x as List).map((y) => (y as num).toDouble()),
                ),
              ),
            )
          : [],
      cooperativeId: json['cooperativeId'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      cooperative: json['cooperative'] != null
          ? Cooperative.fromJson(json['cooperative'])
          : Cooperative(id: 0, nameCooperative: 'Inconnue'),
      stops: (json['stops'] != null)
          ? List<Stop>.from(
              (json['stops'] as List).map((x) => Stop.fromJson(x)),
            )
          : [],
    );
  }

LatLng get centroid {
  if (trace.isEmpty) return LatLng(0,0);
  double latSum = 0;
  double lonSum = 0;
  for (var coord in trace) {
    // coord[0] est longitude, coord[1] est latitude
    lonSum += coord[0];
    latSum += coord[1];
  }
  return LatLng(latSum / trace.length, lonSum / trace.length);
}

}
