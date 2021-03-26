import 'package:graphs/graphs.dart' as graphs;
import '../graphs/directed_graph_base.dart';

/// Provides access to functions offered by the library
/// [graphs]
extension GraphUtils<T extends Object> on DirectedGraphBase<T> {
  /// Returns a valid reverse topological ordering of the
  /// strongly connected components.
  /// Acyclic graphs will yield components containing one vertex only.
  ///
  /// Provided by the library [graphs].
  List<List<T>> get stronglyConnectedComponents {
    return graphs.stronglyConnectedComponents(sortedVertices, edges);
  }

  /// Returns the shortest path between `start` and `target`.
  /// * Returns an empty list if `start` is not connected to `target`.
  /// * Returns an empty list if `start == target`.
  /// * Note: The vertex `start` is list at position `[0]`.
  /// * To include cycles use the method `path(start, target)`.
  /// * Provided by the library [graphs].
  ///
  List<T> shortestPath(T start, T target) {
    final path = graphs.shortestPath(start, target, edges);
    return (path == null) ? <T>[] : path.toList()
      ..insert(0, start);
  }

  /// Returns a `Map` of the shortest paths from `start` to each node
  /// in the directed graph defined by `edges`.
  ///
  /// Provided by the library [graphs].
  Map<T, Iterable<T>> shortestPaths(T start) {
    return graphs.shortestPaths(start, edges);
  }
}
