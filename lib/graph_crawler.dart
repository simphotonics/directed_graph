/// Library providing `GraphCrawler`,
/// a utility class for finding paths connecting
/// two vertices.
library graph_crawler;

import 'dart:collection';
import 'package:meta/meta.dart';

import 'directed_graph.dart';

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

  /// Returns the first detected path from [start] to [target].
  @deprecated
  List<Vertex<T>> pathOld(Vertex<T> start, Vertex<T> target) {
    final _visited = <int, HashSet<int>>{};
    final _queue = Queue<Vertex<T>>();
    var path = <Vertex<T>>[];
    var pathFound = false;

    /// Recursive function that crawls the graph defined by
    /// `edges` and records the first path from [start] to [target].
    void _crawl(Vertex<T> start, Vertex<T> target) {
      // Return if a path has already been found.
      if (pathFound) return;
      _queue.addLast(start);
      for (final vertex in edges(start)) {
        if (vertex == target) {
          // Store result.
          path = List<Vertex<T>>.from(_queue);
          pathFound = true;
          return;
        } else {
          if (_visited[start.id] == null) {
            _visited[start.id] = HashSet();
            _visited[start.id].add(vertex.id);
            _crawl(vertex, target);
          }
          if (_visited[start.id].contains(vertex.id)) {
            continue;
          } else {
            _visited[start.id].add(vertex.id);
            _crawl(vertex, target);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty) {
        _queue.removeLast();
      }
    }

    _crawl(start, target);

    if (path.isEmpty) {
      return path;
    } else {
      return path..add(target);
    }
  }

  /// Returns the paths from [start] vertex to [target] vertex.
  ///
  /// * Each directed edge is walked only once.
  /// * The paths returned may include cycles if the graph is cyclic.
  /// * The algorithm keeps track of the edges already walked to avoid an
  ///    infinite loop when encountering a cycle.
  @deprecated
  List<List<Vertex<T>>> pathsOld(Vertex<T> start, Vertex<T> target) {
    final _visited = <int, HashSet<int>>{};
    final _pathList = <List<Vertex<T>>>[];
    final _queue = Queue<Vertex<T>>();

    /// Adds [this.target] to [path] and appends the result to [_paths].
    void _addPath(List<Vertex<T>> path) {
      // Add target vertex.
      path.add(target);
      _pathList.add(path);
    }

    /// Recursive function that crawls the graph defined by
    /// the function [edges] and records any path from [start] to [target].
    void _crawl(Vertex<T> start, Vertex<T> target) {
      // print('-----------------------');
      // print('Queue: $_queue');
      // print('Start: ${start} => target: ${target}.');
      _queue.addLast(start);
      for (final vertex in edges(start)) {
        // print('$start:${start.id} -> $vertex:${vertex.id}');
        // print('${start} -> ${vertex}');
        // stdin.readLineSync();
        //sleep(Duration(seconds: 2));
        if (vertex == target) {
          // print('|=======> Found target: recording '
          //     'result: $_queue');
          _addPath(_queue.toList());
        } else {
          if (_visited[start.id] == null) {
            _visited[start.id] = HashSet();
            _visited[start.id].add(vertex.id);
            //print('$start -> $vertex added to visited.');
            _crawl(vertex, target);
          }
          if (_visited[start.id].contains(vertex.id)) {
            // print('$start -> $vertex was visited.');
            // print('Choose next vertex:');
            continue;
          } else {
            _visited[start.id].add(vertex.id);
            //print('$start -> $vertex added to visited.');
            _crawl(vertex, target);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty && _queue.last != target) {
        // print('Stepping back');
        // print('$_queue: removing: ${_queue.last}');
        // print('Clearing visited of ${_queue.last}: ${_queue.last._visited}');
        //_queue.removeLast()._visited.clear();
        _queue.removeLast();
      }
    }

    _crawl(start, target);

    return _pathList;
  }

  /// Builds a tree-like structure with [start] as root vertex and returns
  /// the branches ending with [target].
  ///
  /// Aimed at finding paths in **cyclic** directed graphs. It is not
  /// guaranteed that a specific path in a cyclic graph will be found.
  /// If a certain path is not found try the method [paths] and increase the
  /// parameter [maxWalkCount].
  ///
  /// * Each directed edge is walked only once.
  /// * The paths returned may include cycles if the graph is cyclic.
  /// * The algorithm keeps track of the edges already walked to avoid an
  ///    infinite loop when encountering a cycle.
  List<List<Vertex<T>>> fastPaths(
    Vertex<T> start,
    Vertex<T> target, {
    bool stopEarly = false,
  }) {
    final _visited = <int, HashSet<int>>{};
    final _pathList = <List<Vertex<T>>>[];
    var pathFound = false;

    List<List<Vertex<T>>> _growBranch(List<Vertex<T>> branch) {
      if (branch.isEmpty) return [];
      final start = branch.last;
      final branches = <List<Vertex<T>>>[];
      for (final vertex in edges(start)) {
        //stdin.readLineSync();
        if (_visited[start.id] == null) {
          _visited[start.id] = HashSet();
          _visited[start.id].add(vertex.id);
          //print('$start -> $vertex added to visited.');
          branches.add(List<Vertex<T>>.from(branch)..add(vertex));
        } else {
          if (_visited[start.id].contains(vertex.id)) {
            //print('$start -> $vertex was visited.');
            continue;
          } else {
            _visited[start.id].add(vertex.id);
            //print('$start -> $vertex added to visited.');
            branches.add(List<Vertex<T>>.from(branch)..add(vertex));
          }
        }
        if (vertex == target) {
          pathFound == true;
          if (stopEarly) break;
        }
      }
      return branches;
    }

    List<List<Vertex<T>>> _growTree(Vertex<T> start) {
      final tree = <List<Vertex<T>>>[];
      // Add start vertex.
      tree.add([]..add(start));

      // Initialize iteration variables.
      var previousLength = tree.length;
      final previousBranches = <List<Vertex<T>>>[
        [start]
      ];

      // Iteration ends when all edges have been visited at most once.
      do {
        // Update length.
        previousLength = tree.length;

        // Grow new branches
        final newBranches = <List<Vertex<T>>>[];
        for (final branch in previousBranches) {
          final twig = _growBranch(branch);
          if (twig.isEmpty) continue;
          newBranches.addAll(twig);
          if (pathFound && stopEarly) break;
        }

        // Add new branches to tree.
        tree.addAll(newBranches);

        if (pathFound && stopEarly) break;

        //print(tree);
        // Reset previousBranches.
        previousBranches.clear();
        previousBranches.addAll(newBranches);
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
  /// the branches ending with [target].
  ///
  /// Aimed at finding paths in **cyclic** directed graphs. It is not
  /// guaranteed that every path will be found. In a cyclic graph the
  /// higher the [maxWalkCount] the more paths will be found.
  ///
  /// * Each directed edge is walked at most [maxWalkCount] times.
  /// * The paths returned may include cycles if the graph is cyclic.
  /// * The algorithm keeps track of the edges already walked to avoid an
  ///    infinite loop when encountering a cycle.
  List<List<Vertex<T>>> paths(
    Vertex<T> start,
    Vertex<T> target, {
    int maxWalkCount = 1,
  }) {
    final _pathList = <List<Vertex<T>>>[];

    // Retrieve vertex tree.
    final tree = this.tree(
      start,
      maxWalkCount: maxWalkCount,
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
  List<Vertex<T>> path(Vertex<T> start, Vertex<T> target) {
    final _paths = paths(start, target, maxWalkCount: 2);
    return _paths.isEmpty ? [] : _paths.first;
  }

  /// Returns a tree-like structure with [start] as root vertex.
  /// The list entries represent branches and each branch starts with [start].
  ///
  /// * If a [target] vertex is specified, the method will return as soon as
  /// a branch which ends with [target] is found.
  /// * [maxWalkCount] sets the maximum number of times an edge is allowed to be
  /// walked by the algorithm. It provides a cut-off point when applying the
  /// algorithm to cyclic graphs.
  List<List<Vertex<T>>> tree(
    Vertex<T> start, {
    Vertex<T> target,
    int maxWalkCount = 1,
  }) {
    var pathFound = false;
    final visited = <Vertex<T>, Map<Vertex<T>, int>>{};
    final tree = <List<Vertex<T>>>[];
    final _maxWalkCount = (maxWalkCount < 1) ? 1 : maxWalkCount;

    // Add start vertex.
    tree.add([]..add(start));

    List<List<Vertex<T>>> _growBranch(List<Vertex<T>> branch) {
      if (branch.isEmpty) return [];
      final start = branch.last;
      final branches = <List<Vertex<T>>>[];

      for (final vertex in edges(start)) {
        //stdin.readLineSync();
        if (visited[start] == null) {
          visited[start] = <Vertex<T>, int>{};
          visited[start][vertex] = 1;
          branches.add(List<Vertex<T>>.from(branch)..add(vertex));
        } else {
          if (visited[start][vertex] == null) {
            visited[start][vertex] = 1;
            branches.add(List<Vertex<T>>.from(branch)..add(vertex));
          } else {
            if (visited[start][vertex] >= _maxWalkCount) {
              continue;
            } else {
              ++visited[start][vertex];
              branches.add(List<Vertex<T>>.from(branch)..add(vertex));
            }
          }
        }
        if (vertex == target) {
          pathFound = true;
          break;
        }
      }
      return branches;
    }

    // Initialize iteration variables.
    var previousLength = tree.length;
    final previousBranches = <List<Vertex<T>>>[
      [start]
    ];

    // Iteration ends when all edges have been visited at most once.
    do {
      // Update length.
      previousLength = tree.length;

      // Grow new branches
      final newBranches = <List<Vertex<T>>>[];
      for (final branch in previousBranches) {
        final twig = _growBranch(branch);
        if (twig.isEmpty) continue;
        newBranches.addAll(twig);
        if (pathFound) break;
      }

      // Add new branches to tree.
      tree.addAll(newBranches);

      if (pathFound) break;

      //print(tree);
      // Reset previousBranches.
      previousBranches.clear();
      previousBranches.addAll(newBranches);
    } while (tree.length > previousLength);

    return tree;
  }
}
