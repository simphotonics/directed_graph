/// Library providing `GraphCrawler`,
/// a utility class for finding paths connecting
/// two vertices.
library graph_crawler;

import 'dart:collection';
import 'package:meta/meta.dart';

import 'directed_graph.dart' show Edges;

/// Crawls a graph defined by [edges] and records
/// the paths from `start` to `target`.
/// - Note: Directed edges are walked only once.
class GraphCrawler<T> {
  GraphCrawler({
    @required this.edges,
  });

  /// Function returning a list of edge vertices or an empty list.
  /// It must never return `null`.
  final Edges<T> edges;



  /// Returns the shortest paths
  Map<Vertex<T>, List<Vertex<T>>> shortestPaths(
    Vertex<T> start,
    Vertex<T> target,
  ) {
    /// Map storing the shortest paths to each vertex connected
    /// to `start`.
    final shortestPaths = HashMap<Vertex<T>, List<Vertex<T>>>();
    shortestPaths[start] = List(0);

    /// Queue of nodes to be visited next.
    final queue = ListQueue<Vertex<T>>()..add(start);

    var bestOption = <Vertex<T>>[];

    while (queue.isNotEmpty) {
      print(shortestPaths);
      final current = queue.removeFirst();
      final currentPath = shortestPaths[current];
      final currentPathLength = currentPath.length;

      if ((currentPathLength + 1 ) < bestOption.length) {
        // Skip any existing `toVisit` items that have no chance of being
        // better than bestOption (if it exists)
        continue;
      }

      for (final vertex in edges(current)) {
        final existingPath = shortestPaths[vertex];

        // assert(existingPath == null ||
        //     existingPath.length <= (currentPathLength + 1));

        if (existingPath == null) {
          final newOption = List<Vertex<T>>(currentPathLength + 1)
            ..setRange(0, currentPathLength, currentPath)
            ..[currentPathLength] = vertex;

          if (vertex == target) {
            bestOption = newOption;
          }

          shortestPaths[vertex] = newOption;
          if (bestOption.length > newOption.length) {
            // Only add a node to visit if it might be a better path to the
            // target node
            queue.add(vertex);
          }
        }
      }
    }

    return shortestPaths;
  }
}
