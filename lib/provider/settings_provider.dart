import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:proyecto_grafitos/models/path_metadata.dart';
import 'package:proyecto_grafitos/models/vehicle.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/utils/distance_calc.dart';
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

enum Dimension {
  land,
  maritime,
  aerial;

  static Dimension fromString(String other) => switch (other.toLowerCase()) {
    't' => land,
    'a' => aerial,
    'm' => maritime,
    _ => land,
  };
}

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
  EdgeAll? pathAll;
  PathMetadata? pathMetadata;
  bool isdbLoaded = false;
  bool isPathLoading = false;
  List<String>? lastLog;
  bool pathSoftShow = false;

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

  void togglePathSoftShow() {
    pathSoftShow = !pathSoftShow;
    notifyListeners();
  }

  void setPathMetadata(PathMetadata? data) {
    pathMetadata = data;
    notifyListeners();
  }

  void resetPath() {
    pathMetadata = null;
    pathLength = null;
    pathTime = null;
    pathAll = null;

    notifyListeners();
  }

  void setDimension(Dimension value) {
    if (dimension == value) return;

    //paths and selected vertex also should be nulled
    vertexFrom = null;
    vertexTo = null;
    pathLength = null;
    pathTime = null;
    pathAll = null;

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
      setPath(newPathLength: null, newPathTime: null);

      final graph = Graph(vertex, edges);
      if (!useExternal) {
        final resultByTime =
            (searchMode.isEmpty || searchMode.contains(SearchMode.time))
                ? await searchPathByMode(
                  graph: graph,
                  vertexFrom: vertexFrom!,
                  vertexTo: vertexTo!,
                  useAStar: useAStar,
                  mode: SearchMode.time,
                )
                : null;
        final resultByLength =
            (searchMode.isEmpty || searchMode.contains(SearchMode.length))
                ? await searchPathByMode(
                  graph: graph,
                  vertexFrom: vertexFrom!,
                  vertexTo: vertexTo!,
                  useAStar: useAStar,
                  mode: SearchMode.length,
                )
                : null;

        setLastLog([...?resultByTime?.log, ...?resultByLength?.log]);

        final successAtLeastOne = [
          resultByTime,
          resultByLength,
        ].any((res) => res?.existPath(vertexFrom!, vertexTo!) ?? false);

        if (successAtLeastOne) {
          setPath(
            newPathLength: resultByLength?.reconstructPath(vertexFrom!, vertexTo!),
            newPathTime: resultByTime?.reconstructPath(vertexFrom!, vertexTo!),
            silent: true,
          );
          final double leastKmPossible =
              pathAll?.calculateTotalDistance() ??
              pathLength?.calculateTotalDistance() ??
              pathTime!.calculateTotalDistance();
          final double kmForleastTimePossible =
              pathAll?.calculateTotalDistance() ??
              pathTime?.calculateTotalDistance() ??
              pathLength!.calculateTotalDistance();
          pathMetadata = PathMetadata(
            vehicle: selectedVehicle,
            totalDistanceInKm: leastKmPossible,
            estimatedTime: estimateTravelTime(kmForleastTimePossible, selectedVehicle.via),
          );
          ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                "Ruta optima para ${selectedVehicle.matricula}, desde ${vertexFrom!.name} hasta ${vertexTo!.name}",
              ),
            ),
          );
        } else {
          pathMetadata = null;
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
      setPath(newPathLength: null, newPathTime: null);
    }
  }

  void setPath({List<Vertex>? newPathTime, List<Vertex>? newPathLength, bool silent = false}) {
    if (newPathTime != null && newPathLength != null && listEquals(newPathTime, newPathLength)) {
      pathAll = EdgeAll(points: newPathLength.map((v) => v.point).toList());
      pathLength = null;
      pathTime = null;
    } else {
      pathAll = null;
      pathLength =
          newPathLength != null
              ? EdgeLength(points: newPathLength.map((v) => v.point).toList())
              : null;
      pathTime =
          newPathTime != null ? EdgeTime(points: newPathTime.map((v) => v.point).toList()) : null;
    }
    if (!silent) {
      notifyListeners();
    }
  }

  static Future<AlgorithmResult> searchPathByMode({
    required Graph graph,
    required Vertex vertexFrom,
    required Vertex vertexTo,
    required SearchMode mode,
    bool useAStar = true,
  }) async {
    late AlgorithmResult result;
    if (useAStar) {
      result = await compute(
        computeAStar,
        ComputeAStarInput(graph: graph, from: vertexFrom, to: vertexTo, mode: mode),
      );
    } else {
      //dijkstra can be cached :0
      if (dijkstraCache.containsKey(vertexFrom)) {
        result = dijkstraCache[vertexFrom]!;
      } else {
        result = await compute(
          computeDijkstra,
          ComputeDijkstraInput(graph: graph, from: vertexFrom, mode: mode),
        );
        dijkstraCache[vertexFrom] = result as DijkstraResult;
      }
    }
    return result;
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

  Database db = await openDatabase('database.db');

  List<Map<String, Object?>> rawEmployees = await db.rawQuery('SELECT * FROM empleados');
  List<Map<String, Object?>> rawVehicles = await db.rawQuery('SELECT * FROM vehiculo');

  final employees = rawEmployees.map((rawE) => Employee.fromDB(rawE)).toList();
  final vehicles = rawVehicles.map((rawV) => Vehicle.fromDB(rawV)).toList();

  List<Map<String, Object?>> rawEdges = await db.rawQuery('SELECT * FROM caminos');
  List<Map<String, Object?>> rawVertex = await db.rawQuery('SELECT * FROM nodos');

  Map<int, Vertex> processedVertex = {
    for (Vertex v in rawVertex.map(
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
        via: Dimension.fromString(rawVertex['via'] as String),
      ),
    ))
      v.id: v,
  };

  List<Edge> processedEdges =
      rawEdges.map((rawPath) {
        final rawCitiesArray = jsonDecode(rawPath['ruta'] as String) as List<dynamic>;
        return Edge(
          trafficWeight: rawPath['trafico'] as double,
          lengthWeight: rawPath['distancia'] as double,
          points: rawCitiesArray.map((c) => processedVertex[c]!.point).toList(),
          via: Dimension.fromString(rawPath['via'] as String),
        );
      }).toList();

  return ComputeDatabaseResult(
    employees: employees,
    vehicles: vehicles,
    edges: processedEdges,
    vertex: processedVertex.values.toList(),
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
