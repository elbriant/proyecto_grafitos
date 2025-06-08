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

  // log
  final logging = <String>[];

  // Cola de prioridad para nodos abiertos (por explorar)
  final openSet = PriorityQueue<Vertex>((a, b) => (fScore[a]!).compareTo(fScore[b]!));

  /// Función heurística: estima el coste desde [node] al destino
  double heuristic(Vertex node) {
    return node.point.distanceTo(target.point);
  }

  logging.add('※ AStar inició. modo: ${searchMode.toString()}');
  logging.add(
    '※ gScore es el coste acumulado de ese nodo, fScore es el gScore + el coste de heuristica (g + h)',
  );
  logging.add(
    '※ fScore es usado como referencia para el ordenamiento en la cola de prioridad. Menos fScore significa mas priodidad para la busqueda',
  );

  // Inicialización
  for (final vertex in graph.vertices) {
    gScore[vertex] = double.infinity;
    fScore[vertex] = double.infinity;
    logging.add('Inicialización: $vertex gScore: ${gScore[vertex]}, fScore: ${fScore[vertex]}');
  }

  gScore[start] = 0;
  logging.add('$start (nodo inicial) fijado en 0');
  fScore[start] = heuristic(start);
  logging.add('$start (nodo inicial) fScore ${fScore[start]}');
  openSet.add(start);
  logging.add('Cola de prioridad: $openSet');

  // Bucle principal del algoritmo
  int ite = 0;
  while (openSet.isNotEmpty) {
    ite++;
    final current = openSet.removeFirst();
    logging.add('[I-$ite] Nodo seleccionado actual: $current');
    logging.add('[I-$ite] Cola de prioridad: $openSet');

    // Si llegamos al destino, terminamos
    if (current == target) {
      logging.add('[I-$ite] ¡Se llegó al destino! AStar finalizó');
      return AStarResult(logging, gScore, cameFrom);
    }

    // Explorar vecinos
    final neightbours = graph.getNeighbors(current);
    logging.add('[I-$ite] Nodos vecinos: $neightbours');
    for (final neighbor in neightbours) {
      // Calcular coste temporal hasta el vecino
      final tentativeGScore = gScore[current]! + graph.getWeight(current, neighbor, searchMode);
      logging.add('[I-$ite] Nodo vecino $neighbor: peso tentativo $tentativeGScore');

      // Si encontramos un camino mejor
      if (tentativeGScore < gScore[neighbor]!) {
        final lastPrevious = cameFrom[neighbor];
        final lastGScore = gScore[neighbor];
        final lastFScore = fScore[neighbor];
        cameFrom[neighbor] = current;
        gScore[neighbor] = tentativeGScore;
        fScore[neighbor] = tentativeGScore + heuristic(neighbor);
        logging.add(
          '[I-$ite] Se encontró camino mas corto para $neighbor: gScore $lastGScore → ${gScore[neighbor]} / gScore: $lastFScore → ${fScore[neighbor]} / anterior: $lastPrevious → ${cameFrom[neighbor]}',
        );

        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
          logging.add('[I-$ite] se agregó a la cola de priodidad $neighbor: $openSet');
        }
      }
    }
  }

  // Si llegamos aquí, no hay camino al destino
  logging.add('[I-$ite] No se encontró camino hacia el destino. AStar finalizó');
  return AStarResult(logging, gScore, cameFrom);
}
