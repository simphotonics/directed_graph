import '../graphs/graph_crawler.dart';
import '../graphs/weighted_directed_graph.dart';

/// Extension on `WeightedDirectedGraph` providing the methods
/// `lightestPath` and `heaviestPath`.
extension WeightedGraphUtils<T extends Object, W extends Comparable>
    on WeightedDirectedGraph<T, W> {
  /// Returns the path connecting `start` and `target` with
  /// the smallest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> lightestPath(T start, T target) {
    final crawler = GraphCrawler(edges);
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var minWeight = summation(weight, weight);
    var result = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(minWeight) < 0) {
        // Reset minimum weight.
        minWeight = currentWeight;
        result = path;
      }
    }
    return result;
  }

  /// Returns the path connecting `start` and `target` with
  /// the largest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> heaviestPath(T start, T target) {
    final crawler = GraphCrawler(edges);
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var maxWeight = zero;
    var result = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(maxWeight) > 0) {
        // Reset maximum weight.
        maxWeight = currentWeight;
        result = path;
      }
    }
    return result;
  }

  /// Returns the weighted edges representing the
  /// transitive closure of `this`.
  Map<T, Map<T, W>> get transitiveWeightedEdges {
    final tcEdges = <T, Map<T, W>>{};
    final maxWeight = summation(weight, weight);
    final gc = GraphCrawler(edges);
    for (final vertex in sortedVertices) {
      // Weighted edges connected to vertex:
      final weightedEdges = <T, W>{};
      final mappedTree = gc.mappedTree(vertex);
      for (final connectedVertex in mappedTree.keys) {
        // Calculate min. weight.
        var minWeight = maxWeight;
        for (final path in mappedTree[connectedVertex]!) {
          final currentWeight = weightAlong([vertex, ...path]);
          if (currentWeight.compareTo(minWeight) < 0) {
            minWeight = currentWeight;
          }
        }

        weightedEdges[connectedVertex] = minWeight;
      }
      tcEdges[vertex] = weightedEdges;
    }
    return tcEdges;
  }
}
