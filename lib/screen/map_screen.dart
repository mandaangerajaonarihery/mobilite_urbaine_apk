import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:all_pnud/widgets/loading_dialog.dart';
import 'package:all_pnud/services/localisation_service.dart';
import 'package:all_pnud/services/ligne_service.dart';
import 'package:all_pnud/services/parking_services.dart';
import 'package:all_pnud/services/stop_service.dart';
import 'package:all_pnud/services/routing_service.dart';
import 'package:all_pnud/models/ligne.dart';
import 'package:all_pnud/models/parking.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _searchedLocation;

  List<Ligne> _lignes = [];
  List<Parking> _parkings = [];
  List<Stop> _stops = [];
  List<LatLng> _routePolyline = [];
  double? _routeDistance;
  double? _routeDuration;

  bool _didLoadLocation = false;
  final String geoapifyApiKey = '71d43e78df2741edb6b0eb68f74a54d0';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadLocation) {
      final theme = Theme.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLocation(theme);
      });
      _didLoadLocation = true;
    }
  }

  void centerMapToPolyline(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var pt in points) {
      if (pt.latitude < minLat) minLat = pt.latitude;
      if (pt.latitude > maxLat) maxLat = pt.latitude;
      if (pt.longitude < minLng) minLng = pt.longitude;
      if (pt.longitude > maxLng) maxLng = pt.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final spanLat = maxLat - minLat;
    final spanLng = maxLng - minLng;

    double zoom = 14;
    if (spanLat > 0.01 || spanLng > 0.01) zoom = 13;
    if (spanLat > 0.1 || spanLng > 0.1) zoom = 12;
    if (spanLat > 1.0 || spanLng > 1.0) zoom = 10;

    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  Future<void> _loadLocation(ThemeData theme) async {
    final parkingService = ParkingService();
    final ligneService = LigneService();
    final localisationService = LocalisationService();
    final stopService = StopService();
    bool loaderOpen = false;

    try {
      showLoadingDialog(
        context,
        color: theme.colorScheme.tertiary,
        message: "Chargement de la carte...",
      );
      loaderOpen = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (loaderOpen && mounted)
          Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Activez les services de localisation")));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (loaderOpen && mounted)
          Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission localisation refusée")));
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() =>
          _currentLocation = LatLng(position.latitude, position.longitude));

      final result = await localisationService.findArrondissement(
          lat: position.latitude, lng: position.longitude);

      if (result != null && result.containsKey('formatted_id')) {
        final formattedId = result['formatted_id'];

        final lignes = await ligneService.getLignesByMunicipality(formattedId);
        final parkings =
            await parkingService.getParkingsByMunicipality(formattedId);
        final stops = await stopService.getStopsByMunicipality(formattedId);

        if (!mounted) return;
        setState(() {
          _lignes = lignes;
          _parkings = parkings;
          _stops = stops;
        });
      }

      if (loaderOpen && mounted)
        Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 14.0);
      }
    } catch (e) {
      if (loaderOpen && mounted)
        Navigator.of(context, rootNavigator: true).pop();
      debugPrint("Erreur localisation: $e");
    }
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) _mapController.move(_currentLocation!, 15.0);
  }

  Color parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse("0x$hexColor"));
    } catch (_) {
      return Colors.green;
    }
  }

  Future<LatLng?> searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    final response =
        await http.get(url, headers: {'User-Agent': 'AllPNUD App 1.0'});
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

  List<Ligne> getLignesDesservant(LatLng location) {
    const double thresholdMeters = 100;
    final Distance distance = Distance();

    return _lignes.where((ligne) {
      return ligne.trace.any((coord) {
        final point = LatLng(coord[0], coord[1]);
        return distance.as(LengthUnit.Meter, location, point) <=
            thresholdMeters;
      });
    }).toList();
  }

  LatLng getClosestPointOnLine(LatLng userLocation, Ligne ligne) {
    final Distance distance = Distance();
    LatLng closestPoint = LatLng(ligne.trace[0][0], ligne.trace[0][1]);
    double minDist = double.infinity;

    for (var coord in ligne.trace) {
      final point = LatLng(coord[0], coord[1]);
      final dist = distance.as(LengthUnit.Meter, userLocation, point);
      if (dist < minDist) {
        minDist = dist;
        closestPoint = point;
      }
    }
    return closestPoint;
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parking.nomParking,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Places max : ${parking.vehiculeMax}'),
                  Text('Etat : ${parking.etat}'),
                  Text('Tarif horaire : ${parking.tarifHoraire} AR'),
                  if (_routeDistance != null && _routeDuration != null) ...[
                    const SizedBox(height: 14),
                    Text(
                        'Distance estimée: ${(_routeDistance! / 1000).toStringAsFixed(2)} km'),
                    Text(
                        'Durée estimée: ${(_routeDuration! / 60).toStringAsFixed(1)} min'),
                  ],
                  const SizedBox(height: 14),
                  ElevatedButton(
                    child: const Text('Afficher itinéraire'),
                    onPressed: () async {
                      if (_currentLocation == null) return;
                      final routeData = await getRouteGeoapify(
                          _currentLocation!, parking.centroid);
                      setState(() {
                        _routePolyline = routeData['coords'];
                        _routeDistance = routeData['distance'];
                        _routeDuration = routeData['duration'];
                      });
                      centerMapToPolyline(_routePolyline);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ));
  }

  void _showLignesDesservant(LatLng location) {
    final lignes = getLignesDesservant(location);
    if (lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune ligne disponible")));
      return;
    }

    showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Lignes desservant ce lieu",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...lignes.map((ligne) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: parseColor(ligne.couleur),
                          child: Text(ligne.nom[0]),
                        ),
                        title: Text(ligne.nom),
                        onTap: () async {
                          if (_currentLocation == null) return;
                          final closestPoint =
                              getClosestPointOnLine(_currentLocation!, ligne);
                          final routeData = await getRouteGeoapify(
                              _currentLocation!, closestPoint);
                          setState(() {
                            _routePolyline = routeData['coords'];
                            _routeDistance = routeData['distance'];
                            _routeDuration = routeData['duration'];
                          });
                          centerMapToPolyline(_routePolyline);
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte'),
        backgroundColor: const Color(0xFF00C21C),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/apk_pnud')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un lieu...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    if (_searchController.text.isEmpty) return;
                    final loc = await searchLocation(_searchController.text);
                    if (loc != null) {
                      setState(() => _searchedLocation = loc);
                      _mapController.move(loc, 15.0);
                      _showLignesDesservant(loc);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lieu non trouvé")));
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: 14.0,
                    ),
                    children: [
                      // TileLayer Geoapify
                      TileLayer(
                        urlTemplate:
                            'https://maps.geoapify.com/v1/tile/{style}/{z}/{x}/{y}.png?apiKey=$geoapifyApiKey',
                        additionalOptions: {'style': 'osm-carto'},
                        userAgentPackageName: 'com.allpnud.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          ..._lignes.map((ligne) => Polyline(
                                points: ligne.trace
                                    .map((coord) => LatLng(coord[0], coord[1]))
                                    .toList(),
                                color: parseColor(ligne.couleur),
                                strokeWidth: 4.0,
                              )),
                          if (_routePolyline.isNotEmpty)
                            Polyline(
                              points: _routePolyline,
                              color: Colors.blue,
                              strokeWidth: 6.0,
                            ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.my_location,
                                color: Colors.blue, size: 35),
                          ),
                          if (_searchedLocation != null)
                            Marker(
                              point: _searchedLocation!,
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.location_on,
                                  color: Colors.purple, size: 35),
                            ),
                          ..._parkings.map((parking) => Marker(
                                point: parking.centroid,
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () => _showParkingDetails(parking),
                                  child: const Icon(Icons.local_parking,
                                      color: Colors.red, size: 30),
                                ),
                              )),
                          ..._stops.map((stop) => Marker(
                                point: stop.coordinates,
                                width: 35,
                                height: 35,
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Arrêt: ${stop.name}")),
                                    );
                                  },
                                  child: const Icon(Icons.stop_circle,
                                      color: Colors.orange, size: 25),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        backgroundColor: const Color(0xFF00C21C),
        child: const Icon(Icons.gps_fixed, color: Colors.white),
      ),
    );
  }
}
