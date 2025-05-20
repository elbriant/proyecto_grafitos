import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/global_data.dart' show NavigationService;
import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:sqflite/sqflite.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late MapController mapController;
  bool isdbLoaded = false;

  List<Vertex> vertex = [];
  List<Edge> edges = [];

  @override
  void initState() {
    super.initState();

    mapController =
        MapController()
          ..mapEventStream.listen((mapEvent) {
            if (mapEvent.runtimeType == MapEventMove) {
              NavigationService.navigatorKey.currentContext!.read<DebugProvider>().setCurrentZoom(
                mapEvent.camera.zoom,
              );
            }
          });

    loadDBData();
  }

  @override
  void dispose() {
    mapController.dispose();

    super.dispose();
  }

  void markerTapped(int? id) {
    if (id == null) {
      context.read<SettingsProvider>().setButtonLabel(null);
      return;
    }

    Vertex vtx = vertex.firstWhere((e) => e.id == id);
    context.read<SettingsProvider>().setButtonLabel(vtx);
  }

  Future<void> loadDBData() async {
    Database db = await openDatabase('database.db');

    List<Map<String, Object?>> rawEdges = await db.rawQuery('SELECT * FROM caminos');
    List<Map<String, Object?>> rawVertex = await db.rawQuery('SELECT * FROM nodos');

    List<Edge> processedEdges =
        rawEdges.map((rawPath) {
          var rawCityOrigin = rawVertex.firstWhere((e) => e['idNodos'] == rawPath['idNodoOrigen']);
          var rawCityDestiny = rawVertex.firstWhere(
            (e) => e['idNodos'] == rawPath['idNodoDestino'],
          );

          return Edge(
            trafficWeight: rawPath['trafico'] as double,
            lenghtWeight: rawPath['distancia'] as double,
            points: [
              LatLng(rawCityOrigin['latitud'] as double, rawCityOrigin['longitud'] as double),
              LatLng(rawCityDestiny['latitud'] as double, rawCityDestiny['longitud'] as double),
            ],
          );
        }).toList();

    List<Vertex> processedVertex =
        rawVertex
            .map(
              (rawVertex) => Vertex(
                id: rawVertex['idNodos'] as int,
                name: rawVertex['nombre'] as String,
                isCity: (rawVertex['esCiudad'] as int) == 1 ? true : false,
                address: rawVertex['direccion'] as String?,
                rif: rawVertex['rif'] as String?,
                point: LatLng(rawVertex['latitud'] as double, rawVertex['longitud'] as double),
                child: GestureDetector(
                  onTap: () => markerTapped(rawVertex['id'] as int),
                  child: Icon(Icons.location_on),
                ),
              ),
            )
            .toList();

    if (context.mounted) {
      setState(() {
        vertex = processedVertex;
        edges = processedEdges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(11.651018, -70.220401), // En unefa XD
        initialZoom: 18,
        minZoom: 0.5,
        maxZoom: 18,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onLongPress: (tapPosition, point) {
          context.read<DebugProvider>().setLastPoint(point);

          if (context.read<SettingsProvider>().buttonSelection != null) {
            markerTapped(null);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
          userAgentPackageName: 'com.example.proyecto_grafitos',
        ),
        PolylineLayer(polylines: edges),
        MarkerLayer(markers: vertex, rotate: true),
      ],
    );
  }
}
