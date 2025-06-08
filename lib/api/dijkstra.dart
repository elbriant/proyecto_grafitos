import 'package:proyecto_grafitos/models/dijkstra_result.dart';
import 'package:proyecto_grafitos/models/grafo.dart';
import 'package:proyecto_grafitos/models/vertex.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

/// Implementación básica de una cola de prioridad para los algoritmos
/// Utiliza ordenamiento simple para mantener la prioridad
class PriorityQueue<T> {
  final List<T> _elements = [];
  final Comparator<T> _compare;

  /// Constructor que recibe la función de comparación
  PriorityQueue(this._compare);

  /// Añade un elemento a la cola y reordena
  void add(T element) {
    _elements.add(element);
    _elements.sort(_compare);
  }

  T removeFirst() => _elements.removeAt(0);

  void remove(T element) => _elements.remove(element);

  bool get isNotEmpty => _elements.isNotEmpty;

  bool contains(Vertex neighbor) => _elements.contains(neighbor);

  @override
  String toString() {
    return _elements.toString();
  }
}

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
  final priorityQueue = PriorityQueue<Vertex>((a, b) => distances[a]!.compareTo(distances[b]!));

  // log
  final logging = <String>[];

  logging.add('※ Dijkstra inició. modo: ${searchMode.toString()}');

  // Inicialización
  for (final vertex in graph.vertices) {
    distances[vertex] = vertex == start ? 0 : double.infinity;
    previous[vertex] = null;
    logging.add(
      'Inicialización: $vertex distancia: ${distances[vertex]}, anterior: ${previous[vertex]}',
    );
  }

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

      // Si encontramos un camino más corto
      if (totalDistance < distances[neighbor]!) {
        final lastDistance = distances[neighbor];
        final lastPrevious = previous[neighbor];
        distances[neighbor] = totalDistance;
        previous[neighbor] = current;

        // Actualizar la cola de prioridad
        priorityQueue.remove(neighbor);
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
