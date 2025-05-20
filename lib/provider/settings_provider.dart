import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:sqflite/sqflite.dart';

enum SelectButton { from, to }

enum SearchMode { time, length }

class SettingsProvider extends ChangeNotifier {
  SelectButton? buttonSelection;
  Set<SearchMode> searchMode = {};

  List<Vertex> vertex = [];
  List<Edge> edges = [];
  bool isdbLoaded = false;

  Vertex? vertexFrom;
  Vertex? vertexTo;

  void setButtonSelection(SelectButton? value) {
    buttonSelection = value;
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
        notifyListeners();
      case SelectButton.to:
        vertexTo = value;
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
}
