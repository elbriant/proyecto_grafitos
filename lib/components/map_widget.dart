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
  Polyline? lastPA;

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
    final pathAll = context.read<SettingsProvider>().pathAll;
    if ((pathTime != null || pathLength != null || pathAll != null) &&
        (pathTime != lastPT || pathLength != lastPL || pathAll != lastPA)) {
      mapController.fitCamera(
        CameraFit.coordinates(
          coordinates:
              [...?pathTime?.points, ...?pathLength?.points, ...?pathAll?.points].nonNulls.toList(),
          padding: EdgeInsets.all(72.0),
          maxZoom: 18,
          minZoom: 0.5,
        ),
      );
      lastPT = pathTime;
      lastPL = pathLength;
      lastPA = pathAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isdbLoaded = context.select<SettingsProvider, bool>((p) => p.isdbLoaded);

    if (!isdbLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    final dimension = context.select<SettingsProvider, Dimension>((p) => p.dimension);
    final pathIsShowing = context.select<SettingsProvider, bool>((p) => p.pathMetadata != null);

    final pathTime = context.select<SettingsProvider, Polyline?>((p) => p.pathTime);
    final pathLength = context.select<SettingsProvider, Polyline?>((p) => p.pathLength);
    final pathAll = context.select<SettingsProvider, Polyline?>((p) => p.pathAll);
    final completePolyline = [pathTime, pathLength, pathAll].nonNulls.toList();

    final edges =
        context
            .select<SettingsProvider, List<Edge>>((p) => p.edges)
            .where((e) => dimension == e.via)
            .toList();
    List<Vertex> vertex =
        context
            .select<SettingsProvider, List<Vertex>>((p) => p.vertex)
            .where((e) => dimension == e.via)
            .toList();

    if (pathIsShowing) {
      final completePointsList = [for (Polyline poly in completePolyline) ...poly.points];
      vertex = vertex.where((e) => completePointsList.contains(e.point)).toList();
    }

    final fromVertex = context.select<SettingsProvider, Vertex?>((p) => p.vertexFrom);
    final toVertex = context.select<SettingsProvider, Vertex?>((p) => p.vertexTo);
    final zoomLvThreshold = context.select<DebugProvider, bool>((p) => p.currentZoom > 14);

    final forceHideVertex = context.select<DebugProvider, bool>((p) => p.forceHideVertex);
    final forceShowEdges = context.select<DebugProvider, bool>((p) => p.forceShowEdges);
    final softShow = context.select<SettingsProvider, bool>((p) => p.pathSoftShow);

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
          urlTemplate: getDimension(dimension),
          userAgentPackageName: 'com.example.proyecto_grafitos',
        ),
        if ((softShow && zoomLvThreshold) || forceShowEdges) PolylineLayer(polylines: edges),
        PolylineLayer(polylines: completePolyline),
        if (!forceHideVertex)
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: pathIsShowing ? 1 : 75,
              size: const Size(26, 26),
              alignment: Alignment(0, -0.6),
              maxZoom: 18,
              disableClusteringAtZoom: 17,
              rotate: true,
              markers: vertex,
              showPolygon: false,
              builder: (context, markers) {
                if (fromVertex != null && markers.contains(fromVertex)) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.redAccent,
                    ),
                  );
                }

                if (toVertex != null && markers.contains(toVertex)) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                  );
                }

                if (markers.length > 99) return SizedBox.shrink();

                return Opacity(
                  opacity: (99 - markers.length) / 99,
                  child: Container(
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
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
