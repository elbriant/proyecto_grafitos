import 'package:proyecto_grafitos/models/edge.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class Graph {
  final List<Vertex> vertices;
  final List<Edge> edges;

  Graph(this.vertices, this.edges);

  List<Vertex> getNeighbors(Vertex vertex) {
    return edges
        .where((edge) => edge.points.first == vertex.point || edge.points.last == vertex.point)
        .map(
          (edge) =>
              (edge.points.first == vertex.point)
                  ? vertices.singleWhere((e) => e.point == edge.points.last)
                  : vertices.singleWhere((e) => e.point == edge.points.first),
        )
        .toList();
  }

  double getWeight(Vertex source, Vertex target, SearchMode searchMode) {
    final edge = edges.firstWhere(
      (e) =>
          (e.points.first == source.point && e.points.last == target.point) ||
          (e.points.first == target.point && e.points.last == source.point),
      orElse: () => Edge(points: [], trafficWeight: 0, lengthWeight: 0),
    );

    switch (searchMode) {
      case SearchMode.length:
        return edge.lengthWeight;
      case SearchMode.time:
        return edge.lengthWeight * (1 + edge.trafficWeight);
    }
  }
}
