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
    var maxWeight = summation(weight, weight);
    var out = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(maxWeight) < 0) {
        // Reset maximum weight.
        maxWeight = currentWeight;
        out = path;
      }
    }
    return out;
  }

  /// Returns the path connecting `start` and `target` with
  /// the largest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> heaviestPath(T start, T target) {
    final crawler = GraphCrawler(edges);
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var minWeight = zero;
    var out = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(minWeight) > 0) {
        // Reset maximum weight.
        minWeight = currentWeight;
        out = path;
      }
    }
    return out;
  }
}
