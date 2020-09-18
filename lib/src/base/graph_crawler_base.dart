/// Library providing `GraphCrawler`,
/// a utility class for finding paths connecting
/// two vertices.
library graph_crawler;

import 'dart:collection';

/// Function returning a list of edge vertices.
/// If a vertex has no neighbours it should return
/// an empty list.
///
/// Note: The function must never return null.
typedef Edges<T> = Iterable<T> Function(T vertex);

/// A list of connected vertices with an internal occurance count.
class Branch<T> {
  /// Constructs a branch of vertices.
  /// * `vertices` should be a list of connected vertices that can be walked in
  /// the given order.
  Branch(List<T> vertices) : _vertices = List<T>.from(vertices) {
    _vertices.forEach((vertex) =>
        _count[vertex] = _count.containsKey(vertex) ? _count[vertex]! + 1 : 1);
  }

  /// Constructs a copy of a branch.
  Branch.from(Branch<T> branch) : _vertices = List<T>.from(branch._vertices) {
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
  List<Branch<T>> grow(Edges<T> edges, {maxCount = 1}) {
    if (maxCount < 1) maxCount = 1;
    if (_vertices.isEmpty) return [];
    final newBranches = <Branch<T>>[];
    for (final vertex in edges(_vertices.last)) {
      if (_count.containsKey(vertex) && _count[vertex]! >= maxCount) {
        continue;
      } else {
        newBranches.add(Branch.from(this).._add(vertex));
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
  /// the branches ending with [target].
  /// * Each vertex is listed only once.
  /// * The paths returned may include cycles if the graph is cyclic.
  List<List<T>> fastPaths(
    T start,
    T target, {
    bool stopEarly = false,
  }) {
    final _visited = <T, HashSet<T>>{};
    final _pathList = <List<T>>[];
    var pathFound = false;

    List<List<T>> _growBranch(List<T> branch) {
      if (branch.isEmpty) return [];
      final start = branch.last;
      final branches = <List<T>>[];
      for (final vertex in edges(start)) {
        if (_visited[start] == null) {
          _visited[start] = HashSet();
          _visited[start]!.add(vertex);
          branches.add(List<T>.from(branch)..add(vertex));
        } else {
          if (_visited[start]!.contains(vertex)) {
            continue;
          } else {
            _visited[start]!.add(vertex);

            branches.add(List<T>.from(branch)..add(vertex));
          }
        }
        if (vertex == target) {
          pathFound == true;
          if (stopEarly) break;
        }
      }
      return branches;
    }

    List<List<T>> _growTree(T start) {
      final tree = <List<T>>[];
      // Add start vertex.
      tree.add([]..add(start));

      // Initialize iteration variables.
      var previousLength = tree.length;
      var previousBranches = <List<T>>[
        [start]
      ];

      // Iteration ends when all edges have been visited at most once.
      do {
        // Update length.
        previousLength = tree.length;

        // Grow new branches
        final newBranches = <List<T>>[];
        for (final branch in previousBranches) {
          final twig = _growBranch(branch);
          if (twig.isEmpty) continue;
          newBranches.addAll(twig);
          if (pathFound && stopEarly) break;
        }

        // Add new branches to tree.
        tree.addAll(newBranches);

        if (pathFound && stopEarly) break;

        // Reset previousBranches.
        previousBranches = newBranches;
      } while (tree.length > previousLength);

      return tree;
    }

    // Grow vertex tree.
    final tree = _growTree(start);

    // Remove root vertex
    if (tree.isNotEmpty) tree.removeAt(0);

    // Find paths from start to target
    for (final branch in tree) {
      if (branch.last == target) {
        _pathList.add(branch);
      }
    }
    return _pathList;
  }

  /// Builds a tree-like structure with [start] as root vertex and returns
  /// the walks ending with [target].
  ///
  /// Aimed at finding paths in **cyclic** directed graphs.
  /// * Each vertex is liste at most [maxCount] times.
  /// * The paths returned may include cycles if the graph is cyclic.
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

  /// Returns the first detected path from [start] to [target].
  ///
  /// Returns an empty list if no path was found.
  List<T> path(T start, T target) {
    final pathList = <List<T>>[];

    // Retrieve vertex tree.
    final tree = simpleTree(start, target: target);

    // Finding cycles:
    if (start == target) {
      for (final branch in tree) {
        if (edges(branch.last).contains(target)) {
          pathList.add(branch.toList()..add(target));
        }
      }
      return pathList.isEmpty ? [] : pathList.first;
    }

    // Remove root vertex.
    // Otherwise cycles starting with the root vertex will report [root] as
    // a path (see next for-loop).
    if (tree.isNotEmpty) tree.remove({start});

    // Find paths from start to target
    for (final branch in tree) {
      if (branch.last == target) {
        pathList.add(branch.toList());
      }
    }
    return pathList.isEmpty ? [] : pathList.first;
  }

  /// Builds a tree-like structure with [start] as root vertex and returns
  /// the branches ending with [target].
  List<List<T>> paths(T start, T target) {
    final pathList = <List<T>>[];

    // Retrieve vertex tree.
    final tree = simpleTree(start);

    // Finding cycles:
    if (start == target) {
      for (final branch in tree) {
        if (edges(branch.last).contains(target)) {
          pathList.add(branch.toList()..add(target));
        }
      }
      return pathList;
    }

    // Remove root vertex.
    // Otherwise cycles starting with the root vertex will report [root] as
    // a path (see next for-loop).
    if (tree.isNotEmpty) tree.remove({start});

    // Find paths from start to target
    for (final branch in tree) {
      if (branch.last == target) {
        pathList.add(branch.toList());
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
      Branch([start])
    ];

    // Iteration ends when all edges have been visited at most once.
    do {
      // Update length.
      previousLength = tree.length;

      // Grow new branches
      final newBranches = <Branch<T>>[];
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
  /// The set entry represents a path that starts with [start].
  ///
  /// * Each vertex is listed at most once.
  /// * If a [target] vertex is specified, the method will return as soon as
  /// a branch which ends with [target] is found.
  Set<Set<T>> simpleTree(
    T start, {
    T? target,
  }) {
    var pathFound = false;
    final tree = <Set<T>>{};

    // Add start vertex.
    tree.add({}..add(start));

    Set<Set<T>> _growBranch(Set<T> branch) {
      if (branch.isEmpty) return {};
      final newBranches = <Set<T>>{};

      for (final vertex in edges(branch.last)) {
        //stdin.readLineSync();
        if (branch.contains(vertex)) {
          continue;
        } else {
          newBranches.add(Set<T>.from(branch)..add(vertex));
        }
        if (vertex == target) {
          pathFound = true;
          break;
        }
      }
      return newBranches;
    }

    // Initialize iteration variables.
    var previousLength = tree.length;
    var previousBranches = <Set<T>>{
      {start}
    };

    // Iteration ends when all edges have been visited at most once.
    do {
      // Update length.
      previousLength = tree.length;

      // Grow new branches
      final newBranches = <Set<T>>{};
      for (final branch in previousBranches) {
        final twigs = _growBranch(branch);
        if (twigs.isEmpty) continue;
        newBranches.addAll(twigs);
        if (pathFound) break;
      }

      // Add new branches to tree.
      tree.addAll(newBranches);

      if (pathFound) break;

      // Reset previousBranches.
      previousBranches = newBranches;
    } while (tree.length > previousLength);

    return tree;
  }
}
