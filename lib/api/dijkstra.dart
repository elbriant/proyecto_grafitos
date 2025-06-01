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

  // Inicialización
  for (final vertex in graph.vertices) {
    distances[vertex] = vertex == start ? 0 : double.infinity;
    previous[vertex] = null;
  }

  priorityQueue.add(start);

  // Bucle principal del algoritmo
  while (priorityQueue.isNotEmpty) {
    final current = priorityQueue.removeFirst();

    // Explorar todos los vecinos del nodo actual
    for (final neighbor in graph.getNeighbors(current)) {
      final weight = graph.getWeight(current, neighbor, searchMode);
      final totalDistance = distances[current]! + weight;

      // Si encontramos un camino más corto
      if (totalDistance < distances[neighbor]!) {
        distances[neighbor] = totalDistance;
        previous[neighbor] = current;

        // Actualizar la cola de prioridad
        priorityQueue.remove(neighbor);
        priorityQueue.add(neighbor);
      }
    }
  }

  return DijkstraResult(distances, previous);
}
