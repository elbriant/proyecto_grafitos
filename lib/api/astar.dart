import 'dart:typed_data';

import 'package:collection/collection.dart';
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
  // Mapeo de vértices a índices numéricos
  final vertexToIndex = {for (var i = 0; i < graph.vertices.length; i++) graph.vertices[i]: i};
  final indexToVertex = List<Vertex>.from(graph.vertices);

  // Estructuras de datos optimizadas
  final gScore = Float64List(graph.vertices.length)
    ..fillRange(0, graph.vertices.length, double.infinity); // Costes reales acumulados
  final fScore = Float64List(graph.vertices.length)
    ..fillRange(0, graph.vertices.length, double.infinity); // Costes estimados (g + h)

  final cameFrom = List<int?>.filled(graph.vertices.length, null); // Para reconstruir caminos
  final openSet = HeapPriorityQueue<int>(
    (a, b) => fScore[a].compareTo(fScore[b]),
  ); // Cola de prioridad para nodos abiertos (por explorar)

  // log
  final logging = <String>[];

  /// Función heurística optimizada: estima el coste desde [node] al destino
  double heuristic(int nodeIndex) {
    return indexToVertex[nodeIndex].point.distanceTo(target.point);
  }

  logging.add('※ AStar inició. modo: ${searchMode.toString()}');
  logging.add(
    '※ gScore es el coste acumulado de ese nodo, fScore es el gScore + el coste de heuristica (g + h)',
  );
  logging.add(
    '※ fScore es usado como referencia para el ordenamiento en la cola de prioridad. Menos fScore significa mas priodidad para la busqueda',
  );

  logging.add('Inicialización completa para ${graph.vertices.length} nodos (filled)');

  // Inicialización
  final startIndex = vertexToIndex[start]!;
  final targetIndex = vertexToIndex[target]!;

  gScore[startIndex] = 0;
  fScore[startIndex] = heuristic(startIndex);
  openSet.add(startIndex);

  logging.add('$start (nodo inicial) fijado en 0');
  logging.add('$start (nodo inicial) fScore ${fScore[startIndex]}');
  logging.add('Cola de prioridad: $openSet');

  // Bucle principal del algoritmo
  int ite = 0;
  while (openSet.isNotEmpty) {
    ite++;
    final currentIndex = openSet.removeFirst();
    logging.add('[I-$ite] Nodo seleccionado actual: ${indexToVertex[currentIndex]}');
    logging.add('[I-$ite] Cola de prioridad: $openSet');

    // Si llegamos al destino, terminamos
    if (currentIndex == targetIndex) {
      // Reconstrucción del camino
      final path = <Vertex>[];
      var current = targetIndex;

      while (current != startIndex) {
        path.add(indexToVertex[current]);
        current = cameFrom[current]!;
      }
      path.add(indexToVertex[startIndex]);

      // Convertir resultados a formato original
      final resultDistances = {
        for (var i = 0; i < gScore.length; i++)
          if (gScore[i] != double.infinity) indexToVertex[i]: gScore[i],
      };

      final resultPrevious = {
        for (var i = 0; i < cameFrom.length; i++)
          if (cameFrom[i] != null) indexToVertex[i]: indexToVertex[cameFrom[i]!],
      };

      logging.add('[I-$ite] ¡Se llegó al destino! AStar finalizó');
      return AStarResult(logging, resultDistances, resultPrevious);
    }

    // Explorar vecinos
    final neightbours = graph.getNeighbors(indexToVertex[currentIndex]);
    logging.add('[I-$ite] Nodos vecinos: $neightbours');
    for (final neighbor in neightbours) {
      final neighborIndex = vertexToIndex[neighbor]!;
      // Calcular coste temporal hasta el vecino
      final tentativeGScore =
          gScore[currentIndex] + graph.getWeight(indexToVertex[currentIndex], neighbor, searchMode);
      logging.add('[I-$ite] Nodo vecino $neighbor: peso tentativo $tentativeGScore');

      // Si encontramos un camino mejor
      if (tentativeGScore < gScore[neighborIndex]) {
        final lastPrevious = cameFrom[neighborIndex];
        final lastGScore = gScore[neighborIndex];
        final lastFScore = fScore[neighborIndex];
        cameFrom[neighborIndex] = currentIndex;
        gScore[neighborIndex] = tentativeGScore;
        fScore[neighborIndex] = tentativeGScore + heuristic(neighborIndex);
        logging.add(
          '[I-$ite] Se encontró camino mas corto para $neighbor: gScore $lastGScore → ${gScore[neighborIndex]} / gScore: $lastFScore → ${fScore[neighborIndex]} / anterior: $lastPrevious → ${cameFrom[neighborIndex]}',
        );

        // Actualizar la cola de prioridad eficientemente
        if (openSet.contains(neighborIndex)) {
          openSet.remove(neighborIndex);
        }
        openSet.add(neighborIndex);
        logging.add('[I-$ite] se agregó a la cola de priodidad $neighbor: $openSet');
      }
    }
  }

  // Si llegamos aquí, no hay camino al destino
  logging.add('[I-$ite] No se encontró camino hacia el destino. AStar finalizó');
  return AStarResult(logging, {}, {});
}
