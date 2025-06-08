import 'package:proyecto_grafitos/models/algorithm_result.dart';
import 'package:proyecto_grafitos/models/vertex.dart';

/// Contiene los resultados de la ejecución del algoritmo A*.
/// Permite reconstruir caminos y consultar costes.
class AStarResult extends AlgorithmResult {
  /// Mapa de costes reales (g(n)) desde el nodo inicial hasta cada nodo
  final Map<Vertex, double> gScores;

  /// Mapa que indica el nodo anterior en el camino óptimo (para reconstrucción)
  final Map<Vertex, Vertex?> cameFrom;

  AStarResult(super.log, this.gScores, this.cameFrom);

  /// Reconstruye el camino óptimo desde el nodo inicial al destino
  /// [start] nodo inicial
  /// [target] nodo destino
  /// Devuelve una lista ordenada de nodos desde inicio a destino
  @override
  List<Vertex> reconstructPath(Vertex start, Vertex target) {
    final path = <Vertex>[];
    Vertex? current = target;

    if (cameFrom[current] == null && current != start) {
      return []; // No hay camino
    }

    while (current != null) {
      path.insert(0, current);
      current = cameFrom[current];
    }

    return path;
  }

  /// Obtiene el coste total del camino hasta el nodo especificado
  /// [target] nodo destino
  @override
  double getPathCost(Vertex target) {
    return gScores[target] ?? double.infinity;
  }
}
