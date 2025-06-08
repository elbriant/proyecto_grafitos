import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_grafitos/api/astar.dart';
import 'package:proyecto_grafitos/api/dijkstra.dart';
import 'package:proyecto_grafitos/global_data.dart';
import 'package:proyecto_grafitos/models/algorithm_result.dart';
import 'package:proyecto_grafitos/models/astar_result.dart';
import 'package:proyecto_grafitos/models/dijkstra_result.dart';
import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/employee.dart';
import 'package:proyecto_grafitos/models/grafo.dart';
import 'package:proyecto_grafitos/models/vehicle.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/utils/vehicle_select.dart';
import 'package:sqflite/sqflite.dart';

enum SelectButton { from, to }

enum SearchMode {
  time,
  length;

  @override
  String toString() {
    return this == time ? 'tiempo' : 'distancia';
  }
}

enum Dimension { land, maritime, aerial }

Map<Vertex, DijkstraResult> dijkstraCache = {};

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
  List<String>? lastLog;

  Vertex? vertexFrom;
  Vertex? vertexTo;

  void setButtonSelection(SelectButton? value) {
    buttonSelection = value;
    notifyListeners();
  }

  void setLastLog(List<String>? log) {
    lastLog = log;
    notifyListeners();
  }

  void setDimension(Dimension value) {
    if (dimension == value) return;

    //paths and selected vertex also should be nulled
    vertexFrom = null;
    vertexTo = null;
    pathLength = null;
    pathTime = null;

    dimension = value;
    notifyListeners();
  }

  void setDBLoaded(bool value) {
    if (isdbLoaded == value) return;
    isdbLoaded = value;
    notifyListeners();
  }

  void _setVertexEdges({required List<Vertex> ver, required List<Edge> edg, bool? dbValue}) {
    //paths and selected vertex also should be nulled
    vertexFrom = null;
    vertexTo = null;
    pathLength = null;
    pathTime = null;
    isPathLoading = false;

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

    final sex = await compute(computeDatabase, ServicesBinding.rootIsolateToken!);

    employees = sex.employees;
    vehicles = sex.vehicles;

    _setVertexEdges(ver: sex.vertex, edg: sex.edges, dbValue: true);
  }

  Future<void> searchPath(bool useExternal, bool useAStar) async {
    buttonSelection = null;
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
      setPath(null, null);

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

          late AlgorithmResult result;

          if (useAStar) {
            result = await compute(
              computeAStar,
              ComputeAStarInput(graph: graph, from: vertexFrom!, to: vertexTo!, mode: mode),
            );
          } else {
            //dijkstra can be cached :0
            if (dijkstraCache.containsKey(vertexFrom!)) {
              result = dijkstraCache[vertexFrom!]!;
            } else {
              result = await compute(
                computeDijkstra,
                ComputeDijkstraInput(graph: graph, from: vertexFrom!, mode: mode),
              );
              dijkstraCache[vertexFrom!] = result as DijkstraResult;
            }
          }
          pathResult = result.reconstructPath(vertexFrom!, vertexTo!);
          totalWeight = result.getPathCost(vertexTo!);
          setLastLog(result.log);
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
          ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                "Ruta optima para ${selectedVehicle.matricula}, desde ${vertexFrom!.name} hasta ${vertexTo!.name}",
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            NavigationService.navigatorKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text("No existe ruta para esos vertices")));
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

class ComputeDatabaseResult {
  final List<Vertex> vertex;
  final List<Edge> edges;
  final List<Employee> employees;
  final List<Vehicle> vehicles;

  ComputeDatabaseResult({
    required this.vertex,
    required this.edges,
    required this.employees,
    required this.vehicles,
  });
}

Future<ComputeDatabaseResult> computeDatabase(RootIsolateToken dummy) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(dummy);

  databaseFactory = databaseFactorySqflitePlugin;

  Database db = await openDatabase('database.db');

  List<Map<String, Object?>> rawEmployees = await db.rawQuery('SELECT * FROM empleados');
  List<Map<String, Object?>> rawVehicles = await db.rawQuery('SELECT * FROM vehiculo');

  final employees = rawEmployees.map((rawE) => Employee.fromDB(rawE)).toList();
  final vehicles = rawVehicles.map((rawV) => Vehicle.fromDB(rawV)).toList();

  List<Map<String, Object?>> rawEdges = await db.rawQuery('SELECT * FROM caminos');
  List<Map<String, Object?>> rawVertex = await db.rawQuery('SELECT * FROM nodos');

  List<Edge> processedEdges =
      rawEdges.map((rawPath) {
        final rawCitiesArray = jsonDecode(rawPath['ruta'] as String) as List<dynamic>;

        return Edge(
          trafficWeight: rawPath['trafico'] as double,
          lengthWeight: rawPath['distancia'] as double,
          points:
              rawCitiesArray.map((c) {
                var rawCity = rawVertex.firstWhere((e) => e['idNodos'] == c);
                return LatLng(rawCity['latitud'] as double, rawCity['longitud'] as double);
              }).toList(),
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

  return ComputeDatabaseResult(
    employees: employees,
    vehicles: vehicles,
    edges: processedEdges,
    vertex: processedVertex,
  );
}

class ComputeAStarInput {
  final Graph graph;
  final Vertex from;
  final Vertex to;
  final SearchMode mode;

  ComputeAStarInput({
    required this.graph,
    required this.from,
    required this.to,
    required this.mode,
  });
}

AStarResult computeAStar(ComputeAStarInput input) {
  final res = aStar(input.graph, input.from, input.to, input.mode);
  return res;
}

class ComputeDijkstraInput {
  final Graph graph;
  final Vertex from;
  final SearchMode mode;

  ComputeDijkstraInput({required this.graph, required this.from, required this.mode});
}

DijkstraResult computeDijkstra(ComputeDijkstraInput input) {
  final res = dijkstra(input.graph, input.from, input.mode);
  return res;
}
