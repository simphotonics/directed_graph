import 'package:graphs/graphs.dart' as graphs;
import '../graphs/graph_crawler.dart';
import '../graphs/directed_graph_base.dart';

/// Provides access to functions offered by the library `graphs`.
extension GraphUtils<T extends Object> on DirectedGraphBase<T> {
  /// Returns a valid reverse topological ordering of the
  /// strongly connected components.
  /// Acyclic graphs will yield components containing one vertex only.
  List<List<T>> get stronglyConnectedComponents {
    return graphs.stronglyConnectedComponents(sortedVertices, edges);
  }

  /// Returns the shortest path between `start` and `target`.
  /// * Returns an empty list if `start` is not connected to `target`.
  /// * Note: Uses the method `shortestPath` from package: `graphs`.
  /// * Returns an empty list if `start == target`.
  /// * To include cycles use the method `path(start, target)`.
  List<T> shortestPath(T start, T target) {
    final path = graphs.shortestPath(start, target, edges);
    return (path == null) ? <T>[] : path.toList()
      ..insert(0, start);
  }

  /// Returns a `Map` of the shortest paths from `start` to each node
  /// in the directed graph defined by `edges`.
  Map<T, Iterable<T>> shortestPaths(T start) {
    return graphs.shortestPaths(start, edges);
  }

  /// Returns an iterable containing all vertices that are reachable from
  /// vertex `start`.
  Iterable<T> reachableVertices(T start) {
    return GraphCrawler(edges).tree(start).map<T>((branch) => branch.last);
  }

  /// Returns the shortest detected path from [start] to [target]
  /// including cycles.
  /// * Returns an empty list if no path was found.
  /// * To exclude cycles use the method `shortestPath(start, target)`.
  List<T> path(T start, T target) {
    return GraphCrawler(edges).path(start, target);
  }

  /// Returns all paths from [start] to [target]
  /// including cycles.
  /// * Returns an empty list if no path was found.
  /// * To exclude cycles and list only the shortest paths
  ///   use the method `shortestPaths(start, target)`.
  List<List<T>> paths(T start, T target) {
    return GraphCrawler(edges).paths(start, target);
  }
}

/// Extension providing the method cycle();
extension Cycle<T extends Object> on DirectedGraphBase<T> {
  /// Returns the first cycle detected or an empty list
  /// if the graph is acyclic.
  ///
  /// Note: A cycle starts and ends at
  /// the same vertex while inner vertices are distinct.
  List<T> get cycle {
    final start = cycleVertex;
    if (start == null) {
      return <T>[];
    } else {
      final crawler = GraphCrawler<T>(edges);
      return crawler.path(start, start);
    }
  }
}
