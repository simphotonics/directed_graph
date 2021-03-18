import '../graphs/directed_graph_base.dart';
import '../graphs/graph_crawler.dart';

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
