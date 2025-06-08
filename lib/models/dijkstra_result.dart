import 'package:proyecto_grafitos/models/algorithm_result.dart';
import 'package:proyecto_grafitos/models/vertex.dart';

/// Contiene los resultados de la ejecución del algoritmo de Dijkstra.
/// Permite reconstruir los caminos más cortos y consultar las distancias.
class DijkstraResult extends AlgorithmResult {
  /// Mapa de distancias acumuladas desde el nodo inicial hasta cada nodo
  /// Las claves son nodos y los valores son las distancias totales
  final Map<Vertex, double> distances;

  /// Mapa que indica el nodo predecesor en el camino más corto
  /// (para reconstrucción de rutas)
  final Map<Vertex, Vertex?> previous;

  DijkstraResult(super.log, this.distances, this.previous);

  /// Reconstruye el camino más corto desde el nodo inicial al destino
  /// [start] nodo inicial
  /// [target] nodo destino
  /// Devuelve una lista ordenada de nodos desde inicio a destino
  /// Si no hay camino, devuelve una lista vacía
  @override
  List<Vertex> reconstructPath(Vertex start, Vertex target) {
    final path = <Vertex>[];
    Vertex? current = target;

    // Verificar si existe camino
    if (previous[current] == null && current != start) {
      return []; // No hay camino
    }

    // Reconstruir camino retrocediendo
    while (current != null) {
      path.insert(0, current);
      current = previous[current];
    }

    return path;
  }

  /// Obtiene la distancia total del camino más corto al nodo especificado
  /// [target] nodo destino
  @override
  double getPathCost(Vertex target) {
    return distances[target] ?? double.infinity;
  }
}
