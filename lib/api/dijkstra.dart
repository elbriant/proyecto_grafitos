import 'package:collection/collection.dart';
import 'package:proyecto_grafitos/models/dijkstra_result.dart';
import 'package:proyecto_grafitos/models/grafo.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

/// Implementación del algoritmo de Dijkstra para encontrar los caminos más cortos
/// desde un nodo inicial a todos los demás nodos en un grafo ponderado.
///
/// [graph] Grafo sobre el que buscar (debe contener vértices y aristas con pesos)
/// [start] nodo inicial
///
/// Devuelve un objeto DijkstraResult con distancias y predecesores
DijkstraResult dijkstra(Graph graph, Vertex start, SearchMode searchMode) {
  // Estructuras de datos para el algoritmo
  final distances = <Vertex, double>{};
  final previous = <Vertex, Vertex?>{};
  final priorityQueue = HeapPriorityQueue<Vertex>((a, b) => distances[a]!.compareTo(distances[b]!));

  // log
  final logging = <String>[];

  logging.add('※ Dijkstra inició. modo: ${searchMode.toString()}');

  // Lazy initialization
  distances[start] = 0;
  logging.add('Inicialización completa para ${graph.vertices.length} nodos (Lazy)');

  priorityQueue.add(start);
  logging.add('Cola de prioridad: $priorityQueue');

  // Bucle principal del algoritmo
  int ite = 0;
  while (priorityQueue.isNotEmpty) {
    ite++;
    final current = priorityQueue.removeFirst();
    logging.add('[I-$ite] Nodo seleccionado actual: $current');
    logging.add('[I-$ite] Cola de prioridad: $priorityQueue');

    // Explorar todos los vecinos del nodo actual
    final neightbours = graph.getNeighbors(current);
    logging.add('[I-$ite] Nodos vecinos: $neightbours');
    for (final neighbor in neightbours) {
      final weight = graph.getWeight(current, neighbor, searchMode);
      final totalDistance = distances[current]! + weight;
      logging.add('[I-$ite] Nodo vecino $neighbor: peso: $weight, distancia total: $totalDistance');

      // Si encontramos un camino más corto o no está
      if (!distances.containsKey(neighbor) || totalDistance < distances[neighbor]!) {
        final lastDistance = distances[neighbor];
        final lastPrevious = previous[neighbor];
        distances[neighbor] = totalDistance;
        previous[neighbor] = current;

        // Actualizar la cola de prioridad
        // More efficient priority queue update
        if (priorityQueue.contains(neighbor)) {
          priorityQueue.remove(neighbor);
        }
        priorityQueue.add(neighbor);
        logging.add(
          '[I-$ite] Se encontró camino mas corto para $neighbor: distancia $lastDistance → ${distances[neighbor]} / anterior: $lastPrevious → ${previous[neighbor]}',
        );
        logging.add('[I-$ite] Cola de prioridad: $priorityQueue');
      }
    }
  }

  logging.add('[I-$ite] Dijkstra finalizó');

  return DijkstraResult(logging, distances, previous);
}
