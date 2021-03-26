/// Constant holding the largest (smi) int.
///
/// `largeInt = pow(2, 30) - 1;`
const largeInt = 1073741823;

/// Function returning an `Iterable<T>` representing edge vertices.
/// * If `vertex` has no neighbours the function must return
///   an empty iterable.
/// * The function must never return `null`.
typedef Edges<T extends Object> = Iterable<T> Function(T vertex);

/// Utility class for crawling a graph defined by [edges] and
/// retrieving paths and walks.
/// * A directed **path** is defined as a list of connected vertices where
/// each *inner* vertex is listed at most once. The first and the last vertex
/// may be same in order to represent a cycle.
/// * A directed **walk** is defined as a list of connected vertices that can be
/// traversed in sequential order.
class GraphCrawler<T extends Object> {
  GraphCrawler(this.edges);

  /// Function returning an `Iterable<T>` representing edge vertices.
  ///
  /// Important: It must never return `null`.
  final Edges<T> edges;

  /// Returns the shortest detected path from `start` to `target`.
  /// * Returns an empty list if no path was found.
  List<T> path(T start, T target) {
    final _tree = mappedTree(start, target);
    return _tree.containsKey(target)
        ? <T>[start, ..._tree[target]!.first]
        : <T>[];
  }

  /// Returns a list containing all paths connecting `start` and `target`.
  List<List<T>> paths(T start, T target) {
    final pathList = <List<T>>[];
    // Retrieve vertex tree.
    final _tree = mappedTree(start);
    if (_tree.containsKey(target)) {
      for (final branch in _tree[target]!) {
        pathList.add(<T>[start, ...branch]);
      }
    }
    return pathList;
  }

  /// Returns a tree-like structure with `start` as root vertex.
  /// * Each entry of type `Set<T>` represents a path
  ///  (the start vertex is omitted).
  List<Set<T>> tree(T start, [T? target]) {
    final result = <Set<T>>[
      for (final connected in edges(start)) {connected}
    ];

    if (result.isEmpty) return result;

    var startIndexOld = 0;
    var startIndexNew = 0;
    do {
      startIndexNew = result.length;
      for (var i = startIndexOld; i < startIndexNew; ++i) {
        final path = result[i];
        for (final vertex in edges(path.last)) {
          // Discard walks which reach the same (inner) vertex twice.
          // Each path starts with [start] even though it is not
          // listed!
          if (path.contains(vertex) || path.contains(start)) {
            continue;
          } else {
            result.add({...path, vertex});
          }
          if (vertex == target) break;
        }
      }
      startIndexOld = startIndexNew;
    } while (startIndexNew < result.length);
    return result;
  }

  /// Returns a map containing all paths commencing at `start`.
  /// * Paths are grouped according to the last vertex in the path list.
  /// * If a `target` vertex is specified the function will return
  /// as soon as a path from `start` to `target` is found.
  /// * Each entry of type `Set<T>` represents a path (the `start` vertex is omitted).
  /// * Inspired by [`graphs`](https://pub.dev/documentation/graphs/latest/graphs/shortestPaths.html).
  /// Usage:
  ///
  /// ```
  /// import 'package:directed_graph/directed_graph.dart';
  /// void main() {
  ///   var graph = DirectedGraph<String, int>(
  ///     {
  ///       'a': {'a', 'b', 'h', 'c', 'e'},
  ///       'b': {'h'},
  ///       'c': {'h', 'g'},
  ///       'd': {'e', 'f'},
  ///       'e': {'g'},
  ///       'f': {'i'},
  ///       'i': {'l', 'k'},
  ///       'k': {'g', 'f'},
  ///      }
  ///   );
  ///   final crawler = GraphCrawler<String>(graph.edges);
  ///   final treeMap = crawler.mappedTree('a', 'g');
  ///   print(treeMap);
  /// }
  /// ```
  /// The program above generates the following console output:
  ///
  /// `{a: [{a}], b: [{b}], h: [{h}, {b, h}, {c, h}], c: [{c}], e: [{e}], g: [{c, g}]}`
  Map<T, List<Set<T>>> mappedTree(T start, [T? target]) {
    final result = <T, List<Set<T>>>{};
    final _tree = tree(start, target);
    for (final branch in _tree) {
      if (result.containsKey(branch.last)) {
        result[branch.last]!.add(branch);
      } else {
        result[branch.last] = [branch];
      }
    }
    return result;
  }
}
