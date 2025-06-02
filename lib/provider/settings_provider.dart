import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_grafitos/api/astar.dart';
import 'package:proyecto_grafitos/api/dijkstra.dart';
import 'package:proyecto_grafitos/global_data.dart';
import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/employee.dart';
import 'package:proyecto_grafitos/models/grafo.dart';
import 'package:proyecto_grafitos/models/vehicle.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/utils/vehicle_select.dart';
import 'package:sqflite/sqflite.dart';

enum SelectButton { from, to }

enum SearchMode { time, length }

enum Dimension { land, maritime, aerial }

class SettingsProvider extends ChangeNotifier {
  SelectButton? buttonSelection;
  Set<SearchMode> searchMode = {};

  List<Vertex> vertex = [];
  List<Edge> edges = [];
  List<Employee> employees = [];
  List<Vehicle> vehicles = [];
  Dimension dimension = Dimension.land;
  EdgeLength? pathLength;
  EdgeTime? pathTime;
  bool isdbLoaded = false;
  bool isPathLoading = false;

  Vertex? vertexFrom;
  Vertex? vertexTo;

  void setButtonSelection(SelectButton? value) {
    buttonSelection = value;
    notifyListeners();
  }

  void setDimension(Dimension value) {
    if (dimension == value) return;
    dimension = value;
    notifyListeners();
  }

  void setDBLoaded(bool value) {
    if (isdbLoaded == value) return;
    isdbLoaded = value;
    notifyListeners();
  }

  void _setVertexEdges({required List<Vertex> ver, required List<Edge> edg, bool? dbValue}) {
    vertex = ver;
    edges = edg;
    if (dbValue != null) {
      isdbLoaded = dbValue;
    }
    notifyListeners();
  }

  void setButtonLabel(Vertex? value) {
    switch (buttonSelection) {
      case SelectButton.from:
        vertexFrom = value;
        if (vertexTo == value) {
          vertexTo = null;
        }
        notifyListeners();
      case SelectButton.to:
        vertexTo = value;
        if (vertexFrom == value) {
          vertexFrom = null;
        }
        notifyListeners();
      default:
        break;
    }
  }

  void setSearchMode(Set<SearchMode> value) {
    searchMode = value;
    notifyListeners();
  }

  void markerTapped(int? id) {
    if (id == null) {
      setButtonLabel(null);
      return;
    }

    Vertex vtx = vertex.firstWhere((e) => e.id == id);
    setButtonLabel(vtx);
  }

  Future<void> loadDBData() async {
    setDBLoaded(false);
    Database db = await openDatabase('database.db');

    List<Map<String, Object?>> rawEmployees = await db.rawQuery('SELECT * FROM empleados');
    List<Map<String, Object?>> rawVehicles = await db.rawQuery('SELECT * FROM vehiculo');

    employees = rawEmployees.map((rawE) => Employee.fromDB(rawE)).toList();
    vehicles = rawVehicles.map((rawV) => Vehicle.fromDB(rawV)).toList();

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
            lengthWeight: rawPath['distancia'] as double,
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
                address: rawVertex['direccion'] as String?,
                rif: rawVertex['rif'] as String?,
                point: LatLng(rawVertex['latitud'] as double, rawVertex['longitud'] as double),
                child: VertextIcon(
                  isCity: (rawVertex['esCiudad'] as int) == 1 ? true : false,
                  vertexId: rawVertex['idNodos'] as int,
                ),
              ),
            )
            .toList();

    _setVertexEdges(ver: processedVertex, edg: processedEdges, dbValue: true);
  }

  Future<void> searchPath(bool useExternal, bool useAStar) async {
    if (vertexFrom != null && vertexTo != null) {
      final Vehicle? selectedVehicle = await showVehicleModal(
        NavigationService.navigatorKey.currentContext!,
        vehicles,
        employees,
      );

      if (selectedVehicle == null) {
        ScaffoldMessenger.of(
          NavigationService.navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Selecciona un vehiculo")));
        return;
      }

      isPathLoading = true;
      notifyListeners();

      // TODO: implement logging of algoryhtm
      // TODO: implement compute to nice detail
      final graph = Graph(vertex, edges);
      if (!useExternal) {
        List<Vertex> pathResult = [];
        double totalWeight = double.infinity;
        bool successAtLeastOne = false;

        // do both and skip if one is selected
        for (SearchMode mode in SearchMode.values) {
          if (searchMode.isNotEmpty && mode != searchMode.first) {
            continue;
          }

          if (useAStar) {
            final resultA = aStar(graph, vertexFrom!, vertexTo!, mode);
            pathResult = resultA.reconstructPath(vertexFrom!, vertexTo!);
            totalWeight = resultA.getPathCost(vertexTo!);
          } else {
            final resultD = dijkstra(graph, vertexFrom!, mode);
            pathResult = resultD.getShortestPath(vertexFrom!, vertexTo!);
            totalWeight = resultD.getPathCost(vertexTo!);
          }
          // print('Camino más corto por ${mode}: $pathResult');
          // print('Peso total (distancia o tráfico): ${resultD.distances[vertexTo]}');
          final resbol = setPath(
            pathResult,
            mode,
            totalWeight: totalWeight,
            omitNullingLast: searchMode.isEmpty,
          );
          if (resbol) {
            successAtLeastOne = resbol;
          }
        }
        if (successAtLeastOne) {
          ScaffoldMessenger.of(
            NavigationService.navigatorKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text("ruta para ${selectedVehicle.matricula}")));
        } else {
          ScaffoldMessenger.of(
            NavigationService.navigatorKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text("ruta para no existe camino")));
        }
      } else {
        // XD
        // hernesto momento
      }
      isPathLoading = false;
      notifyListeners();
    } else {
      // make an snackbar
      ScaffoldMessenger.of(
        NavigationService.navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("falta algun vertice")));
      setPath(null, null);
    }
  }

  /// returns true if success
  bool setPath(
    List<Vertex>? path,
    SearchMode? mode, {
    double? totalWeight,
    bool omitNullingLast = false,
  }) {
    if (!omitNullingLast) {
      pathLength = null;
      pathTime = null;
    }

    if (mode == null && path == null) {
      //reset both
      pathLength = null;
      pathTime = null;
      notifyListeners();
      return true;
    }

    if ((path?.isEmpty ?? false) && totalWeight == double.infinity) {
      //doesnt exists
      pathLength = null;
      pathTime = null;
      notifyListeners();
      return false;
    }

    switch (mode) {
      case SearchMode.length:
        pathLength = path != null ? EdgeLength(points: path.map((v) => v.point).toList()) : null;
      case SearchMode.time:
        pathTime =
            path != null
                ? EdgeTime(
                  points: path.map((v) => v.point).toList(),
                  pattern: StrokePattern.dashed(segments: [6.0, 6.0]),
                )
                : null;
      default:
        pathLength = path != null ? EdgeLength(points: path.map((v) => v.point).toList()) : null;
        pathTime =
            path != null
                ? EdgeTime(
                  points: path.map((v) => v.point).toList(),
                  pattern: StrokePattern.dashed(segments: [6.0, 6.0]),
                )
                : null;
    }
    notifyListeners();
    return true;
  }
}
