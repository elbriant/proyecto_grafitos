import 'package:latlong2/latlong.dart';
import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class Graph {
  final List<Vertex> vertices;
  final List<Edge> edges;
  final _neighborCache = <Vertex, List<Vertex>>{};
  final _vertexPointMap = <LatLng, Vertex>{};
  final _edgeMap = <(LatLng, LatLng), Edge>{}; // Using point tuples

  Graph(this.vertices, this.edges);

  void buildCaches() {
    _neighborCache.clear();
    _vertexPointMap.clear();
    _edgeMap.clear();

    // Build vertex point map
    for (final vertex in vertices) {
      _vertexPointMap[vertex.point] = vertex;
    }

    // Build neighbor cache
    for (final edge in edges) {
      final v1 = _vertexPointMap[edge.points.first]!;
      final v2 = _vertexPointMap[edge.points.last]!;

      final key = (edge.points.first, edge.points.last);
      final reverseKey = (edge.points.last, edge.points.first);

      _edgeMap[key] = edge;
      _edgeMap[reverseKey] = edge;

      _neighborCache.putIfAbsent(v1, () => []).add(v2);
      _neighborCache.putIfAbsent(v2, () => []).add(v1);
    }
  }

  List<Vertex> getNeighbors(Vertex vertex) {
    return _neighborCache[vertex] ?? [];
  }

  double getWeight(Vertex source, Vertex target, SearchMode searchMode) {
    final edge = _edgeMap[(source.point, target.point)];
    if (edge == null) return double.infinity;

    switch (searchMode) {
      case SearchMode.length:
        return edge.lengthWeight;
      case SearchMode.time:
        return edge.lengthWeight * (1 + edge.trafficWeight);
    }
  }

  Vertex getVertexByPoint(LatLng point) {
    return _vertexPointMap[point]!;
  }
}
