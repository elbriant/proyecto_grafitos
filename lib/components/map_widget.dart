import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/global_data.dart' show NavigationService;
import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late MapController mapController;

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

    NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().loadDBData();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isdbLoaded = context.select<SettingsProvider, bool>((p) => p.isdbLoaded);

    if (!isdbLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    final edges = context.select<SettingsProvider, List<Edge>>((p) => p.edges);
    final vertex = context.select<SettingsProvider, List<Vertex>>((p) => p.vertex);

    // example purposes
    final edgeTime = EdgeTime(
      points: [LatLng(11.674, -70.172), LatLng(11.391, -69.667), LatLng(10.5042441, -66.8935222)],
      pattern: StrokePattern.dashed(segments: [6.0, 6.0]),
    );
    final edgeLength = EdgeLength(
      points: [
        LatLng(11.674, -70.172),
        LatLng(11.391, -69.667),
        LatLng(10.0784, -69.323),
        LatLng(10.5042441, -66.8935222),
      ],
    );

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
            context.read<SettingsProvider>().markerTapped(null);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
          userAgentPackageName: 'com.example.proyecto_grafitos',
        ),
        PolylineLayer(polylines: edges),
        PolylineLayer(polylines: [edgeTime, edgeLength]),
        MarkerLayer(markers: vertex, rotate: true, alignment: Alignment(0, -0.6)),
      ],
    );
  }
}
