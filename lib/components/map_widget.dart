import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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
  Polyline? lastPT;
  Polyline? lastPL;

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

  String getDimension(Dimension dimension) {
    return switch (dimension) {
      Dimension.land => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      Dimension.aerial => 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      Dimension.maritime => 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    };
  }

  Future<void> showContextMenu(TapPosition tapPosition, LatLng point, BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(tapPosition.global, tapPosition.global),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          onTap: () {
            ScaffoldMessenger.of(
              NavigationService.navigatorKey.currentContext!,
            ).showSnackBar(SnackBar(content: Text("No implementado XD")));
          },
          child: Text("Crear nodo aqui (WIP)"),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pathTime = context.read<SettingsProvider>().pathTime;
    final pathLength = context.read<SettingsProvider>().pathLength;
    if ((pathTime != null || pathLength != null) && (pathTime != lastPT || pathLength != lastPL)) {
      mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [...?pathTime?.points, ...?pathLength?.points].nonNulls.toList(),
          padding: EdgeInsets.all(72.0),
          maxZoom: 18,
          minZoom: 0.5,
        ),
      );
      lastPT = pathTime;
      lastPL = pathLength;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isdbLoaded = context.select<SettingsProvider, bool>((p) => p.isdbLoaded);

    if (!isdbLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    final dimension = context.select<SettingsProvider, Dimension>((p) => p.dimension);

    // TODO: implement filtering by dimension
    final edges =
        context
            .select<SettingsProvider, List<Edge>>((p) => p.edges)
            .where((e) => dimension == Dimension.land)
            .toList();
    final vertex =
        context
            .select<SettingsProvider, List<Vertex>>((p) => p.vertex)
            .where((e) => dimension == Dimension.land)
            .toList();

    final pathTime = context.select<SettingsProvider, Polyline?>((p) => p.pathTime);
    final pathLength = context.select<SettingsProvider, Polyline?>((p) => p.pathLength);
    final pathAll = context.select<SettingsProvider, Polyline?>((p) => p.pathAll);

    final zoomLv = context.select<DebugProvider, double>((p) => p.currentZoom);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(11.651018, -70.220401), // En unefa XD
        initialZoom: 7,
        minZoom: 0.5,
        maxZoom: 18,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onLongPress: (tapPosition, point) {
          context.read<DebugProvider>().setLastPoint(point);

          if (context.read<SettingsProvider>().buttonSelection != null) {
            context.read<SettingsProvider>().markerTapped(null);
          } else {
            showContextMenu(tapPosition, point, context);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: getDimension(dimension), // For demonstration only
          userAgentPackageName: 'com.example.proyecto_grafitos',
        ),
        if (zoomLv > 6.5) PolylineLayer(polylines: edges),
        PolylineLayer(polylines: [pathTime, pathLength, pathAll].nonNulls.toList()),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            alignment: Alignment(0, -0.6),
            padding: const EdgeInsets.all(50),
            maxZoom: 15,
            rotate: true,
            markers: vertex,
            showPolygon: false,
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
