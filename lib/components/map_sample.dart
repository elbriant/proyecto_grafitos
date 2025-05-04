import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/global_data.dart' show NavigationService;
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:sqflite/sqflite.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late MapController mapController;
  bool isdbLoaded = false;

  List<Vertex> vertex = [];
  List<Polyline> path = [];

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
    context.read<SettingsProvider>().setButtonLabel(vtx.name);
  }

  Future<void> loadDBData() async {
    Database db = await openDatabase('database.db');

    List<Map<String, Object?>> rawPaths = await db.rawQuery('SELECT * FROM caminos');
    List<Map<String, Object?>> rawVertexC = await db.rawQuery('SELECT * FROM ciudades');
    List<Map<String, Object?>> rawVertexE = await db.rawQuery('SELECT * FROM empresas');

    List<Polyline> processedPaths =
        rawPaths.map((rawPath) {
          var rawCityOrigin = rawVertexC.firstWhere(
            (e) => e['id'] == rawPath['Id_ciudad_origen'],
            orElse: () => rawVertexE.firstWhere((e) => e['id'] == rawPath['Id_ciudad_origen']),
          );
          var rawCityDestiny = rawVertexC.firstWhere(
            (e) => e['id'] == rawPath['Id_ciudad_destino'],
            orElse: () => rawVertexE.firstWhere((e) => e['id'] == rawPath['Id_ciudad_destino']),
          );

          return Polyline(
            points: [
              LatLng(rawCityOrigin['latitud']! as double, rawCityOrigin['longitud']! as double),
              LatLng(rawCityDestiny['latitud']! as double, rawCityDestiny['longitud']! as double),
            ],
          );
        }).toList();

    List<Vertex> processedVertexC =
        rawVertexC
            .map(
              (rawVertex) => Vertex(
                id: rawVertex['id']! as int,
                name: rawVertex['nombre']! as String,
                point: LatLng(rawVertex['latitud']! as double, rawVertex['longitud']! as double),
                child: GestureDetector(
                  onTap: () => markerTapped(rawVertex['id']! as int),
                  child: Icon(Icons.location_on),
                ),
              ),
            )
            .toList();

    // List<Marker> processedVertexE =
    //     rawVertexE
    //         .map(
    //           (rawVertex) => Marker(
    //             point: LatLng(rawVertex['latitud']! as double, rawVertex['longitud']! as double),
    //             child: Icon(Icons.location_city),
    //           ),
    //         )
    //         .toList();

    if (context.mounted) {
      setState(() {
        vertex = [...processedVertexC];
        path = processedPaths;
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
        PolylineLayer(polylines: path),
        MarkerLayer(markers: vertex, rotate: true),
      ],
    );
  }
}
