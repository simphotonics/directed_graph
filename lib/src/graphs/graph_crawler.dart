/// Library providing `GraphCrawler`,
/// a utility class for finding paths connecting
/// two vertices.
library graph_crawler;

import 'dart:collection';

/// Constant holding the largest (smi) int.
///
/// `largeInt = pow(2, 30) - 1;`
const largeInt = 1073741823;

/// Function returning a list of edge vertices.
/// If a vertex has no neighbours it should return
/// an empty list.
///
/// Note: The function must never return null.
typedef Edges<T> = Iterable<T> Function(T vertex);

/// A list of connected vertices with an internal occurance count.
class _Branch<T> {
  /// Constructs a branch of vertices.
  /// * `vertices` should be a list of connected vertices that can be walked in
  /// the given order.
  _Branch(List<T> vertices) : _vertices = List<T>.from(vertices) {
    _vertices.forEach((vertex) =>
        _count[vertex] = _count.containsKey(vertex) ? _count[vertex]! + 1 : 1);
  }

  /// Constructs a copy of a branch.
  _Branch.from(_Branch<T> branch) : _vertices = List<T>.from(branch._vertices) {
    _count.addAll(branch._count);
  }

  /// Vertex occurance counter.
  final _count = <T, int>{};

  /// A list of connected vertices.
  final List<T> _vertices;

  /// Adds a new vertex and increments the vertex occurance counter.
  void _add(T vertex) {
    _vertices.add(vertex);
    _count[vertex] = _count.containsKey(vertex) ? _count[vertex]! + 1 : 1;
  }

  /// Returns a list with entries of type `Branch<T>`.
  /// * `maxCount` is the maximum number of times a vertex may be repeated in
  /// a walk along the branch.
  /// * `maxCount` must be larger than zero.
  List<_Branch<T>> grow(Edges<T> edges, {maxCount = 1}) {
    if (maxCount < 1) maxCount = 1;
    if (_vertices.isEmpty) return [];
    final newBranches = <_Branch<T>>[];
    for (final vertex in edges(_vertices.last)) {
      if (_count.containsKey(vertex) && _count[vertex]! >= maxCount) {
        continue;
      } else {
        newBranches.add(_Branch.from(this).._add(vertex));
      }
    }
    return newBranches;
  }

  @override
  String toString() {
    return _vertices.toString();
  }
}

/// Utility class for crawling a graph defined by [edges] and
/// retrieving paths and walks connecting `start` and `target`.
/// * A directed **path** is defined as a list of connected vertices where
/// each *inner* vertex is listed at most once. The first and the last vertex
/// may be same in order to represent a cycle.
/// * A directed **walk** is defined as a list of connected vertices that can be
/// traversed in the given order.
class GraphCrawler<T> {
  GraphCrawler(this.edges);

  /// Function returning a list of edge vertices or an empty list.
  /// It must never return `null`.
  final Edges<T> edges;

  /// Builds a tree-like structure with [start] as root vertex and returns
  /// the walks ending with [target].
  ///
  /// Aimed at finding walks in **cyclic** directed graphs.
  /// * Each vertex is listed at most [maxCount] times.
  List<List<T>> walks(
    T start,
    T target, {
    int maxCount = 1,
  }) {
    final _pathList = <List<T>>[];

    // Retrieve vertex tree.
    final tree = this.tree(
      start,
      maxCount: maxCount,
    );

    // Remove root vertex.
    // Otherwise cycles starting with the root vertex will report [root] as
    // a path (see next for-loop).
    if (tree.isNotEmpty) tree.removeAt(0);

    // Find paths from start to target
    for (final branch in tree) {
      if (branch.last == target) {
        _pathList.add(branch);
      }
    }
    return _pathList;
  }

  /// Returns the shortest detected path from [start] to [target].
  /// * Returns an empty list if no path was found.
  List<T> path(T start, T target) {
    // Retrieve vertex tree.
    final tree = simpleTree(start);
    // Finding shortest branch.
    var shortestBranchLength = largeInt;
    var shortestBranch = <T>{};

    for (final branch in tree) {
      if (branch.isEmpty) continue;
      if (branch.last == target) {
        if (branch.length == 1) {
          // There cannot be a shorter branch.
          return <T>[start, ...branch];
        } else {
          if (shortestBranchLength > branch.length) {
            shortestBranchLength = branch.length;
            shortestBranch = branch;
          }
        }
      }
    }

    return shortestBranch.isEmpty ? <T>[] : <T>[start, ...shortestBranch];
  }

  /// Builds a tree-like structure with [start] as root vertex and returns
  /// the branches ending with [target].
  List<List<T>> paths(T start, T target) {
    final pathList = <List<T>>[];

    // Retrieve vertex tree.
    final tree = simpleTree(start);

    // Find paths from start to target
    for (final branch in tree) {
      if (branch.isEmpty) continue;
      if (branch.last == target) {
        pathList.add(<T>[start, ...branch]);
      }
    }
    return pathList;
  }

  /// Returns a tree-like structure with [start] as root vertex.
  /// The list entries represent branches and each branch starts with [start].
  ///
  /// * If a [target] vertex is specified, the method will return as soon as
  /// a branch which ends with [target] is found.
  /// * In a branch each vertex is listed at most [maxCount] times.
  List<List<T>> tree(
    T start, {
    T? target,
    int maxCount = 1,
  }) {
    var targetFound = false;

    final tree = <List<T>>[];
    maxCount = (maxCount < 1) ? 1 : maxCount;

    // Add start vertex.
    tree.add([]..add(start));

    // Initialize iteration variables.
    var previousLength = tree.length;
    var previousBranches = [
      _Branch([start])
    ];

    // Iteration ends when all edges have been visited at most once.
    do {
      // Update length.
      previousLength = tree.length;

      // Grow new branches
      final newBranches = <_Branch<T>>[];
      for (final branch in previousBranches) {
        final branches = branch.grow(edges, maxCount: maxCount);
        if (branches.isEmpty) continue;
        for (final newBranch in branches) {
          if (newBranch._vertices.isNotEmpty) {
            newBranches.add(newBranch);
            if (newBranch._vertices.last == target) {
              targetFound = true;
              break;
            }
          }
        }
      }

      // Add new branches to tree.
      tree.addAll(newBranches.map<List<T>>((branch) => branch._vertices));

      // Break if target is found.
      if (targetFound) break;

      // Reset previousBranches.
      previousBranches = newBranches;
    } while (tree.length > previousLength);
    return tree;
  }

  /// Returns a tree-like structure with [start] as root vertex.
  /// * Each entry of type `Set<T>` represents a path
  ///   (the start vertex is omitted).
  List<Set<T>> simpleTree(T start) {
    final tree = <Set<T>>[
      for (final connected in edges(start)) {connected}
    ];

    if (tree.isEmpty) return tree;

    var startOld = 0;
    var startNew = 0;
    do {
      startNew = tree.length;
      for (var i = startOld; i < startNew; ++i) {
        final path = tree[i];
        for (final vertex in edges(path.last)) {
          // Discard walks which reach the same (inner) vertex twice.
          // Each path starts with [start] even though the vertex is not
          // listed!
          if (path.contains(vertex) || path.contains(start)) {
            continue;
          } else {
            tree.add({...path, vertex});
          }
        }
      }
      // print(tree);
      // print('$startNew => ${tree.length}');
      // stdin.readLineSync();
      startOld = startNew;
    } while (startNew < tree.length);
    return tree;
  }

  /// Returns a map containing all paths commencing at [start].
  /// * Paths are grouped according to the last vertex in the path list.
  /// * If a [target] vertex is specified the function return as soon as a path
  ///  from [start] to [target] is found.
  /// * Each entry of type `Set<T>` represents a path (the [start] vertex is omitted).
  /// * Inspired by [`graphs`](https://pub.dev/documentation/graphs/latest/graphs/shortestPaths.html).
  ///
  /// Example:
  /// ```
  /// import 'package:directed_graph/directed_graph.dart';
  /// void main(List<String> args) {
  ///   int comparator(
  ///     String s1,
  ///     String s2,
  ///   ) {
  ///     return s1.compareTo(s2);
  ///   }
  ///
  ///   var graph = DirectedGraph<String, int>(
  ///     {
  ///       'a': {'b', 'h', 'c', 'e'},
  ///       'b': {'h'},
  ///       'c': {'h', 'g'},
  ///       'd': {'e', 'f'},
  ///       'e': {'g'},
  ///       'f': {'i'},
  ///       'i': {'l', 'k'},
  ///       'k': {'g', 'f'},
  ///       'l': {'l'}
  ///     },
  ///     comparator: comparator,
  ///   );
  ///
  ///   final crawler = GraphCrawler<String>(graph.edges);
  ///   final treeMap = crawler.mappedTree('d');
  ///   print(treeMap);
  ///   // Prints: {e: [{e}], f: [{f}], g: [{e, g}, {f, i, k, g}], i: [{f, i}], l: [{f, i, l}], k: [{f, i, k}]}
  /// }
  /// ```
  Map<T, List<Set<T>>> mappedTree(T start, {T? target}) {
    final tree = <T, List<Set<T>>>{};
    final visited = <T>{};
    final queue = ListQueue<T>()..add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      for (final connected in edges(current)) {
        // print('$current => $connected');
        if (tree[current] == null) {
          tree[connected] ??= [
            {connected}
          ];
        } else {
          tree[connected] = [
            ...?tree[connected],
            for (final path in tree[current]!)
              // Filter out any path that intersects itself.
              if (!path.contains(connected)) Set<T>.from(path)..add(connected)
          ];
        }
        if (!visited.contains(connected)) {
          queue.add(connected);
          visited.add(connected);
        }
        // stdin.readLineSync();
        // print(queue);
        // print(tree);
      }
    }

    return tree;
  }
}
