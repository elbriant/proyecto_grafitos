import 'package:proyecto_grafitos/models/vertex.dart';

abstract class AlgorithmResult {
  final List<String> log;

  AlgorithmResult(this.log);

  List<Vertex> reconstructPath(Vertex start, Vertex target);
  double getPathCost(Vertex target);
}
