/// Constant holding the largest (smi) int.
///
/// `largeInt = pow(2, 30) - 1;`
const largeInt = 1073741823;

final largestInt = double.maxFinite.floor();

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

  /// Returns the shortest path from `start` to `target`.
  /// * Returns an empty list if `target` is not reachable from `start`.
  List<T> path(T start, T target) {
    final tree = <Set<T>>[];
    for (final connected in edges(start)) {
      if (connected == target) {
        // Return early if start is connected to target.
        return <T>[start, target];
      } else if (connected == start) {
        // Do not follow self-loops.
        continue;
      } else {
        // Store first branches of tree.
        tree.add({connected});
      }
    }

    // No path detected.
    if (tree.isEmpty) return <T>[];

    var startIndex = 0;
    var endIndex = 0;
    var length = tree.length;
    do {
      endIndex = tree.length;
      for (var i = startIndex; i < endIndex; ++i) {
        final path = tree[i];
        for (final vertex in edges(path.last)) {
          // Discard walks which reach the same (inner) vertex twice.
          // Note: Each path starts with [start] even though it is not
          // listed!
          if (path.contains(vertex) || path.contains(start)) {
            continue;
          } else {
            if (vertex == target) {
              // Shortest path found!
              return [start, ...path, vertex];
            } else {
              // Continue growing tree.
              tree.add({...path, vertex});
              length++;
            }
          }
        }
      }
      startIndex = endIndex;
    } while (endIndex < length);
    // No path detected:
    return <T>[];
  }

  /// Returns a list containing all paths connecting `start` and `target`.
  List<List<T>> paths(T start, T target) {
    final pathList = <List<T>>[];
    // // Retrieve vertex tree.
    // final tree = mappedTree(start);
    // if (tree.containsKey(target)) {
    //   for (final branch in tree[target]!) {
    //     pathList.add(<T>[start, ...branch]);
    //   }
    // }
    final tree = <Set<T>>[];
    for (final connected in edges(start)) {
      if (connected == target) {
        // Add to list of paths
        pathList.add([start, target]);
      } else if (connected == start) {
        // Do not follow self-loops.
        continue;
      } else {
        // Store first branches of tree.
        tree.add({connected});
      }
    }

    // There is no other path (except for self-loops from `start` to `start`).
    if (tree.isNotEmpty) {
      var startIndex = 0;
      var endIndex = 0;
      var length = tree.length;
      do {
        endIndex = tree.length;
        for (var i = startIndex; i < endIndex; ++i) {
          final path = tree[i];
          for (final vertex in edges(path.last)) {
            // Discard walks which reach the same (inner) vertex twice.
            // Note: Each path starts with [start] even though it is not
            // listed!
            if (path.contains(vertex) || path.contains(start)) {
              continue;
            } else {
              if (vertex == target) {
                // Store detected path:
                pathList.add([start, ...path, vertex]);
              } else {
                // Continue growing tree.
                tree.add({...path, vertex});
                length++;
              }
            }
          }
        }
        startIndex = endIndex;
      } while (endIndex < length);
    }
    return pathList;
  }

  /// Returns a map containing the shortest paths from
  /// `start` to each reachable vertex.
  /// The map keys represent the set of vertices reachable from `start`.
  Map<T, Iterable<T>> shortestPaths(T start) {
    final pathMap = <T, Iterable<T>>{};

    final tree = <Set<T>>[];
    for (final connected in edges(start)) {
      pathMap[connected] = ([connected]);
      if (connected != start) {
        // Do not follow self-loops.
        // Store first branches of tree.
        tree.add({connected});
      }
    }

    if (tree.isNotEmpty) {
      var startIndex = 0;
      var endIndex = 0;
      var length = tree.length;
      do {
        endIndex = tree.length;
        for (var i = startIndex; i < endIndex; ++i) {
          final path = tree[i];
          for (final vertex in edges(path.last)) {
            // Discard walks which reach the same (inner) vertex twice.
            // Note: Each path starts with [start] even though it is not
            // listed!
            if (path.contains(vertex) || path.contains(start)) {
              continue;
            } else {
              // Store path to new vertex.
              pathMap[vertex] ??= ([...path, vertex]);

              // Continue growing tree.
              tree.add({...path, vertex});
              length++;
            }
          }
        }
        startIndex = endIndex;
      } while (endIndex < length);
    }
    return pathMap;
  }

  /// Returns a tree-like structure with `start` as root vertex.
  /// * Each entry of type `Set<T>` represents a path
  ///  (the start vertex is omitted).
  /// * If a `target` vertex is provided the function returns
  /// as soon as a branch reaching `target` is added to the tree.
  List<Set<T>> tree(T start, [T? target]) {
    final result = <Set<T>>[];

    for (final connected in edges(start)) {
      result.add({connected});
      if (connected == target) {
        return result;
      }
    }

    if (result.isEmpty) return result;

    var startIndex = 0;
    var endIndex = 0;
    var length = result.length;
    do_loop:
    do {
      endIndex = result.length;
      for (var i = startIndex; i < endIndex; ++i) {
        final path = result[i];
        for (final vertex in edges(path.last)) {
          // Discard walks which reach the same (inner) vertex twice.
          // Each path starts with [start] even though it is not
          // listed!
          if (path.contains(vertex) || path.contains(start)) {
            continue;
          } else {
            result.add({...path, vertex});
            length++;
          }
          if (vertex == target) break do_loop;
        }
      }
      startIndex = endIndex;
    } while (endIndex < length);
    return result;
  }

  /// Returns a map containing all paths commencing at `start`.
  /// * Each entry of type `Set<T>` represents a path
  ///   (the `start` vertex is omitted).
  /// * Paths are grouped according to the last vertex in the path list.
  /// * If a `target` vertex is specified the function will return
  /// after a path from `start` to `target` was found and added to the map.
  /// * Inspired by [`graphs`](https://pub.dev/documentation/graphs/latest/graphs/shortestPaths.html).
  ///
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
    final tree = this.tree(start, target);
    for (final branch in tree) {
      if (result.containsKey(branch.last)) {
        result[branch.last]!.add(branch);
      } else {
        result[branch.last] = [branch];
      }
    }
    return result;
  }
}
