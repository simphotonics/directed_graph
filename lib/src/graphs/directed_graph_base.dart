import 'dart:collection';
import 'package:directed_graph/src/extensions/sort.dart';
import 'package:lazy_memo/lazy_memo.dart';
import 'package:quote_buffer/quote_buffer.dart';

import 'graph_crawler.dart';

const int cyclicMarker = -1;

/// Abstract base class of a directed graph.
abstract class DirectedGraphBase<T extends Object> extends Iterable<T> {
  /// Super constructor of objects extending `DirectedGraphBase`.
  /// * `comparator`: A function with signature `int Function(T a, T b)`
  /// used to sort vertices.
  DirectedGraphBase(
    Comparator<T>? comparator,
  ) : _comparator = comparator;

  /// The comparator used to sort vertices.
  Comparator<T>? _comparator;

  /// Returns the comparator used to sort graph vertices.
  Comparator<T>? get comparator => _comparator;

  /// Sets the comparator used to sort graph vertices.
  set comparator(Comparator<T>? comparator) {
    _comparator = comparator;
    _sortedVertices.updateCache();
  }

  /// Returns `true` if [comparator] is not null.
  bool get hasComparator => _comparator != null;

  /// Marks cached variables as stale.
  /// This method must be called every time vertices or edges
  /// are *added* or *removed* from the graph.
  ///
  /// After calling this method
  /// all cached variables will be recalculated when next accessed.
  void updateCache() {
    _outDegreeMap.updateCache();
    _inDegreeMap.updateCache();
    _sortedVertices.updateCache();
  }

  /// Caches the sorted vertices.
  late final Lazy<Set<T>> _sortedVertices =
      Lazy<Set<T>>(() => vertices.toSet()..sort(comparator));

  /// Returns an `Iterable<T>` of all vertices.
  Iterable<T> get vertices;

  /// Returns an `Iterable<T>` of all vertices sorted using `comparator`.
  Iterable<T> get sortedVertices => _sortedVertices();

  /// Returns the vertices connected to `vertex`.
  Iterable<T> edges(T vertex);

  /// Returns `True` if there is an edge pointing from
  /// `vertexOut` to `vertexIn`. Returns `False` otherwise.
  bool edgeExists(T vertexOut, T vertexIn);

  /// Returns `True` if `vertex` is a graph vertex.
  /// Returns `False` otherwise.
  bool vertexExists(T vertex);

  // Returns a mapping between vertex and number of
  /// outgoing connections.
  late final _outDegreeMap = LazyMap<T, int>(() {
    final map = <T, int>{};
    for (final vertex in sortedVertices) {
      map[vertex] = edges(vertex).length;
    }
    return map;
  });

  // Returns a mapping between vertex and number of
  /// outgoing connections.
  Map<T, int> get outDegreeMap => _outDegreeMap();

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  late final _inDegreeMap = LazyMap<T, int>(() {
    var map = <T, int>{};
    for (final vertex in sortedVertices) {
      // Entry might already exist.
      map[vertex] ??= 0;
      for (final connectedVertex in edges(vertex)) {
        map[connectedVertex] =
            map.containsKey(connectedVertex) ? map[connectedVertex]! + 1 : 1;
      }
    }
    return map;
  });

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<T, int> get inDegreeMap => _inDegreeMap();

  /// The graph crawler of this graph.
  late final GraphCrawler<T> crawler = GraphCrawler<T>(edges);

  /// Returns an iterable containing all vertices that are reachable from
  /// vertex `start`.
  Set<T> reachableVertices(T start) {
    return crawler.tree(start).map<T>((branch) => branch.last).toSet();
  }

  /// Returns the shortest detected path from `start` to `target`
  /// including cycles.
  /// * Returns an empty list if no path was found.
  /// * To exclude cycles use the method `shortestPath(start, target)`.
  List<T> path(T start, T target) {
    return crawler.path(start, target);
  }

  /// Returns all paths from `start` to `target`
  /// including cycles.
  /// * Returns an empty list if no path was found.
  /// * To exclude cycles and list only the shortest paths
  ///   use the method `shortestPaths(start, target)`.
  List<List<T>> paths(T start, T target) {
    return crawler.paths(start, target);
  }

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
      return crawler.path(start, start);
    }
  }

  /// Returns the first vertex detected
  /// that is part of a cycle.
  ///
  /// Returns `null` if the graph is acyclic.
  T? get cycleVertex {
    // Start vertex of the cycle.
    T? start;
    final temp = HashSet<T>();
    final perm = HashSet<T>();
    // Marks [this] graph as acyclic.
    var isCyclic = false;
    // Recursive function
    void visit(T vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // _Vertex has permanent mark.
      // => This vertex and its neighbouring
      //    vertices have already been visited.
      if (perm.contains(vertex)) return;
      // A cycle has been detected. Mark graph as acyclic.
      if (temp.contains(vertex)) {
        start = vertex;
        isCyclic = true;
        return;
      }
      // Temporary mark. Marks current vertex as visited.
      temp.add(vertex);
      for (final connectedVertex in edges(vertex)) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      perm.add(vertex);
    }

    // Main loop
    for (final vertex in sortedVertices) {
      if (isCyclic) break;
      visit(vertex);
    }
    return start;
  }

  /// Returns true if the graph is a directed acyclic graph.
  bool get isAcyclic => (cycleVertex == null) ? true : false;

  /// Returns a list of type `List<List<T>>`.
  /// The first entry contains the
  /// local source vertices of the graph.
  /// Subsequent entries contain the local source vertices of the reduced graph.
  /// The reduced graph is obtained by removing all vertices listed in
  /// previous entries from the original graph.
  ///
  /// Note: Concatenating the entries of [localSources] in sequential order
  ///       results in a topological ordering of the graph vertices.
  ///
  /// Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  List<List<T>>? get localSources {
    final result = <List<T>>[];

    final vertices = LinkedHashSet<T>.of(sortedVertices);
    final localInDegreeMap = inDegreeMap;

    var hasSources = false;
    var count = 0;

    // Note: In an acyclic directed graph at least one
    // vertex has outDegree zero.
    do {
      // Storing local sources.
      final sources = <T>[];

      // Find local sources.
      for (final vertex in vertices) {
        if (localInDegreeMap[vertex] == 0) {
          sources.add(vertex);
          ++count;
        }
      }

      // Add sources to result:
      if (sources.isNotEmpty) result.add(sources);

      // Simulate the removal of detected local sources.
      for (final source in sources) {
        for (final connectedVertex in edges(source)) {
          localInDegreeMap[connectedVertex] =
              localInDegreeMap[connectedVertex]! - 1;
        }
      }
      // Check if local sources were found.
      hasSources = sources.isNotEmpty;
      vertices.removeAll(sources);
    } while (hasSources);

    return (count == length) ? result : null;
  }

  /// Returns an ordered set of all vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * If a vertex comparator is specified, the sorting will be applied
  /// in addition to the topological order.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop renders a directed graph cyclic.
  /// * Based on Kahn's algorithm.
  Set<T>? get sortedTopologicalOrdering {
    if (_comparator == null) return topologicalOrdering;

    final result = Queue<T>();

    int inverseComparator(T left, T right) => -_comparator!(left, right);

    // Get modifiable in-degree map.
    final localInDegreeMap = inDegreeMap;

    // Add all sources (vertices with inDegree == 0) to queue.
    // Using a list instead of a queue to enable sorting of [sources].
    //
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    final sources = <T>[];
    for (final vertex in sortedVertices) {
      if (localInDegreeMap[vertex] == 0) {
        sources.add(vertex);
      }
    }
    // Initialize count of visited vertices.
    var count = 0;

    // Note: In an acyclic directed graph at least
    // one vertex has outDegree zero.
    while (sources.isNotEmpty) {
      // Sort source vertices:
      sources.sort(inverseComparator);
      result.add(sources.removeLast());

      // Simulate removing the current vertex from the
      //   graph. => Connected vertices will have inDegree = inDegree - 1.
      for (final vertex in edges(result.last)) {
        localInDegreeMap[vertex] = localInDegreeMap[vertex]! - 1;

        // Add new local source vertices of the remaining graph to the queue.
        if (localInDegreeMap[vertex] == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }
    return (count != length) ? null : result.toSet();
  }

  /// Returns a set containing all graph vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// * Based on a depth-first search algorithm (Cormen 2001, Tarjan 1976).
  Set<T>? get topologicalOrdering {
    final queue = Queue<T>();
    final perm = HashSet<T>();
    final temp = HashSet<T>();

    // Marks graph as cyclic.
    var isCyclic = false;

    // Recursive function
    void visit(T vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // Vertex has permanent mark.
      // => This vertex and its neighbouring vertices
      // have already been visited.
      if (perm.contains(vertex)) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (temp.contains(vertex)) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      temp.add(vertex);
      for (final connectedVertex in edges(vertex)) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      // We tried all options.
      perm.add(vertex);
      queue.addFirst(vertex);
    }

    // Main loop
    // Note: Iterating in reverse order of [vertices]
    // (approximately) preserves the
    // sorting of vertices (on top of the topological sorting.)
    // For a sorted topological ordering use
    // the getter: [sortedTopologicalOrdering].
    //
    // Iterating in normal order of [vertices] yields a different
    // valid topological sorting.
    for (final vertex in sortedVertices.toList().reversed) {
      visit(vertex);
      if (isCyclic) break;
    }

    // Return null if graph is not a DAG.
    return (isCyclic) ? null : queue.toSet();
  }

  /// Returns the number of outgoing directed edges for [vertex].
  /// * Note: Returns `null` if `vertex` does not belong to the graph.
  int? outDegree(T vertex) {
    return vertexExists(vertex) ? edges(vertex).length : null;
  }

  /// Returns the number of incoming directed edges for [vertex].
  ///
  /// Returns `null` if `vertex` is not a graph vertex.
  int? inDegree(T vertex) {
    if (!vertexExists(vertex)) {
      return null;
    }
    var inDegree = 0;
    for (final start in vertices) {
      if (edgeExists(start, vertex)) {
        ++inDegree;
      }
    }
    return inDegree;
  }

  /// Returns a string representation of the graph.
  @override
  String toString() {
    var b = StringBuffer();
    final q = (T == String) ? '\'' : '';
    final isString = (T == String);
    b.writeln('{');
    for (final vertex in sortedVertices) {
      b.write(' $q$vertex$q: ');
      b.write('{');
      if (isString) {
        b.writeAllQ(edges(vertex));
      } else {
        b.writeAll(edges(vertex), ', ');
      }

      b.write('},');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }
}
