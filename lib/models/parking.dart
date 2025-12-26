import 'package:latlong2/latlong.dart';

class Parking {
  final int id;
  final String nomParking;
  final String etat;
  final int? vehiculeMax;
  final int tarifHoraire;
  final List<List<LatLng>> localisation;

  Parking({
    required this.id,
    required this.nomParking,
    required this.etat,
    this.vehiculeMax,
    required this.tarifHoraire,
    required this.localisation,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    final localisationRaw = json['localisation'] ?? [];
    List<List<LatLng>> localisationParsed = [];

    for (var zone in localisationRaw) {
      List<LatLng> points = [];
      for (var point in zone) {
        // point = [lng, lat]
        points.add(LatLng(point[1], point[0]));
      }
      localisationParsed.add(points);
    }

    return Parking(
      id: json['id_parking'],
      nomParking: json['nom_parking'] ?? '',
      etat: json['etat'] ?? 'libre',
      vehiculeMax: json['vehicule_max'],
      tarifHoraire: json['tarif_horaire'],
      localisation: localisationParsed,
    );
  }

  LatLng get centroid {
    if (localisation.isEmpty || localisation[0].isEmpty) {
      return LatLng(0, 0);
    }
    final polygon = localisation[0];
    double latSum = 0;
    double lngSum = 0;
    for (var point in polygon) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    return LatLng(latSum / polygon.length, lngSum / polygon.length);
  }

  get municipalityId => null; // A compléter si nécessaire
}
