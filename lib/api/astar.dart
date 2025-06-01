import 'package:proyecto_grafitos/api/dijkstra.dart';
import 'package:proyecto_grafitos/models/astar_result.dart';
import 'package:proyecto_grafitos/models/grafo.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:proyecto_grafitos/utils/distance_calc.dart';

/// Implementación del algoritmo A* para encontrar el camino óptimo en un grafo.
/// [graph] Grafo sobre el que buscar
/// [start] nodo inicial
/// [target] nodo destino
/// [searchMode] modo de busqueda
/// Devuelve un objeto AStarResult con los resultados de la búsqueda
AStarResult aStar(Graph graph, Vertex start, Vertex target, SearchMode searchMode) {
  final cameFrom = <Vertex, Vertex?>{}; // Para reconstruir caminos
  final gScore = <Vertex, double>{}; // Costes reales acumulados
  final fScore = <Vertex, double>{}; // Costes estimados (g + h)

  // Cola de prioridad para nodos abiertos (por explorar)
  final openSet = PriorityQueue<Vertex>((a, b) => (fScore[a]!).compareTo(fScore[b]!));

  /// Función heurística: estima el coste desde [node] al destino
  double heuristic(Vertex node) {
    return node.point.distanceTo(target.point);
  }

  // Inicialización
  for (final vertex in graph.vertices) {
    gScore[vertex] = double.infinity;
    fScore[vertex] = double.infinity;
  }

  gScore[start] = 0;
  fScore[start] = heuristic(start);
  openSet.add(start);

  // Bucle principal del algoritmo
  while (openSet.isNotEmpty) {
    final current = openSet.removeFirst();

    // Si llegamos al destino, terminamos
    if (current == target) {
      return AStarResult(gScore, cameFrom);
    }

    // Explorar vecinos
    for (final neighbor in graph.getNeighbors(current)) {
      // Calcular coste temporal hasta el vecino
      final tentativeGScore = gScore[current]! + graph.getWeight(current, neighbor, searchMode);

      // Si encontramos un camino mejor
      if (tentativeGScore < gScore[neighbor]!) {
        cameFrom[neighbor] = current;
        gScore[neighbor] = tentativeGScore;
        fScore[neighbor] = tentativeGScore + heuristic(neighbor);

        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }
      }
    }
  }

  // Si llegamos aquí, no hay camino al destino
  return AStarResult(gScore, cameFrom);
}
