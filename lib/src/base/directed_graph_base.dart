
import 'dart:collection' show Queue, UnmodifiableListView;

import 'graph_crawler_base.dart';

// import 'package:graphs/graphs.dart' as graphs;

/// Generic directed graph storing vertices of type `T`.
///
/// The data-type `T` should be usable as a map key.
class DirectedGraph<T> extends Iterable {
  /// Constructs a directed graph from a map of type `Map<T, List<T>>`.
  DirectedGraph(
    Map<T, Set<T>> data, {
    Comparator<T>? comparator,
  }) : _comparator = comparator {
    data.forEach((vertex, connectedVertices) {
      _edges[vertex] = Set<T>.of(connectedVertices);
      for (final connectedVertex in connectedVertices) {
        _edges[connectedVertex] ??= <T>{};
      }
    });
  }

  /// Factory constructor returning the transitive closure of [directedGraph].
  // factory DirectedGraph.transitiveClosure(DirectedGraph<T> directedGraph) =>
  //     DirectedGraph(
  //       transitiveClosure(directedGraph.data),
  //       comparator: directedGraph.comparator,
  //     );

  final Map<T, Set<T>> _edges = {};

  /// Backup of sorted vertices.
  /// * Do not access this field outside the getter `_vertices`.
  /// * To get a list of sorted vertices use `_vertices`.
  var _verticesBackup = <T>[];

  /// Marks sorted vertices as up to date.
  var _isUpToDate = false;

  UnmodifiableListView<T> get vertices => UnmodifiableListView(_vertices);

  /// Returns a list of sorted vertices.
  /// Vertices are sorted if a comparator was specified.
  List<T> get _vertices {
    if (_isUpToDate) return _verticesBackup;
    var vertices = _edges.keys.toList();
    if (_comparator != null) vertices.sort(_comparator);
    // Mark _verticesBackup as up to date.
    _isUpToDate = true;
    _verticesBackup = vertices;
    return vertices;
  }

  /// The comparator used to sort vertices.
  Comparator<T>? _comparator;

  /// Returns the comparator used to sort graph vertices.
  Comparator<T>? get comparator => _comparator;

  /// Sets the comparator used to sort graph vertices.
  set comparator(Comparator<T>? comparator) {
    _comparator = comparator;
    // final data = this.data;
    // data.forEach((vertex, connectedVertices) {
    //   _edges[vertex] = Set.of(connectedVertices);
    // });
    _isUpToDate = false;
  }

  /// Returns the underlying graph data as a map of type `Map<T, Set<T>>`.
  Map<T, Set<T>> get data {
    final data = <T, Set<T>>{};
    for (final vertex in _edges.keys) {
      data[vertex] = _edges[vertex]!;
    }
    return data;
  }

  /// Returns the vertices connected to [vertex].
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  Iterable<T> edges(T vertex) => _edges[vertex] ?? <T>{};

  /// Adds edges (connections) pointing from [vertex] to [connectedVertices].
  void addEdges(T vertex, Set<T> connectedVertices) {
    if (_edges[vertex] == null) {
      // If vertex is new add it to the graph.
      _edges[vertex] = Set.of(connectedVertices);
    } else {
      _edges[vertex]!.addAll(connectedVertices);
    }
    for (final connectedVertex in connectedVertices) {
      // If connectedVertex is new add it to the graph.
      _edges[connectedVertex] ??= <T>{};
    }
    _isUpToDate = false;
  }

  /// Removes edges (connections) pointing from [vertex] to [connectedVertices].
  /// * If `connectedVertices` is not specified all outgoing
  /// edges of `vertex` are removed from the graph.
  /// * Note: Does not remove the vertices.
  void removeEdges(T vertex, [Set<T> connectedVertices = const {}]) {
    _edges[vertex]?.removeAll(connectedVertices);
  }

  /// Removes edges ending at [vertex] from the graph.
  void removeIncomingEdges(T vertex) {
    if (_edges[vertex] == null) return;
    for (final connectedVertices in _edges.values) {
      connectedVertices.remove(vertex);
    }
  }

  /// Completely remove [vertex] from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    if (_edges[vertex] == null) return;
    removeEdges(vertex);
    removeIncomingEdges(vertex);
    _edges.remove(vertex);
  }

  // /// Returns a valid reverse topological ordering of the
  // /// strongly connected components.
  // /// Acyclic graphs will yield components containing one vertex only.
  // List<List<T>> get stronglyConnectedComponents {
  //   return graphs.stronglyConnectedComponents<T>(_vertexMap.keys, edges);
  // }

  // /// Returns the shortest path between [start] and [target].
  // /// * Returns `null` if [start] is not connected to [target].
  // /// * Return an empty list if [start] is equal to [target].
  // List<T> shortestPath(T start, T target) {
  //   return graphs.shortestPath<T>(start, target, edges);
  // }

  // /// Returns a `Map` of the shortest paths from [start] to each node
  // /// in the directed graph defined by [edges].
  // Map<T, List<T>> shortestPaths(T start) {
  //   return graphs.shortestPaths<T>(start, edges);
  // }

  /// Returns true if the graph is a directed acyclic graph.
  bool get isAcyclic {
    return (topologicalOrdering == null) ? false : true;
  }

  /// Returns a list of type `List<List<_Vertex<T>>>`.
  /// The first entry contains the
  /// local source vertices of the graph.
  /// Subsequent entries contain the local source vertices of the reduced graph.
  /// The reduced graph is obtained by removing all vertices listed in
  /// previous entries from the original graph.
  ///
  /// Note: Concatenating the entries of [localSources()] in sequential order
  ///       results in a topological ordering of the graph vertices.
  ///
  /// Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  List<List<T>>? get localSources {
    final result = <List<T>>[];

    // Get modifiable in-degree map.
    final _inDegreeMap = inDegreeMap;

    // Get modifiable list of the graph vertices
    final vertices = this.vertices.toSet();

    var hasSources = false;
    var count = 0;

    // Note: In an acyclic directed graph at least one
    // vertex has outDegree zero.
    do {
      // Storing local sources.
      final sources = <T>[];

      // Find local sources.
      for (final vertex in vertices) {
        if (_inDegreeMap[vertex] == 0) {
          sources.add(vertex);
          ++count;
        }
      }

      // Add sources to result:
      if (sources.isNotEmpty) result.add(sources);

      // Simulate the removal of detected local sources.
      for (final source in sources) {
        for (final connectedVertex in _edges[source]!) {
          _inDegreeMap[connectedVertex] = _inDegreeMap[connectedVertex]! - 1;
        }
      }
      // Check if local source were found.
      hasSources = sources.isNotEmpty;
      vertices.removeAll(sources);
    } while (hasSources);

    return (count == length) ? result : null;
  }

  /// Returns a list of all vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * If a vertex comparator is specified, the sorting will be applied
  /// in addition to the topological order. If
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// * Based on Kahn's algorithm.
  List<T>? get sortedTopologicalOrdering {
    if (_comparator == null) return topologicalOrdering;

    final result = <T>[];

    // Get modifiable in-degree map.
    final inDegreeMap = this.inDegreeMap;

    // Add all sources (vertices with inDegree == 0) to queue.
    // Using a list instead of a queue to enable sorting of [sources].
    //
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    final sources = <T>[];
    for (final vertex in _edges.keys) {
      if (inDegreeMap[vertex] == 0) {
        sources.add(vertex);
      }
    }
    // Initialize count of visited vertices.
    var count = 0;

    // Note: In an acyclic directed graph at least
    // one vertex has outDegree zero.
    while (sources.isNotEmpty) {
      // Sort source vertices:
      sources.sort(_comparator);
      var current = sources.removeAt(0);
      result.add(current);

      // Simulate removing the current vertex from the
      //   graph. => Connected vertices with have inDegree = inDegree - 1.
      for (final vertex in _edges[current]!) {
        inDegreeMap[vertex] = inDegreeMap[vertex]! - 1;

        // Add new local source vertices of the remaining graph to the queue.
        if (inDegreeMap[vertex] == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }
    return (count != length) ? null : result;
  }

  /// Returns `List<_Vertex<T>>`, a list of all vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// * Based on a depth-first search algorithm (Cormen 2001, Tarjan 1976).
  List<T>? get topologicalOrdering {
    final queue = Queue<T>();
    final tab = <T, int>{};

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
      if (tab[vertex] == -3) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (tab[vertex] == -2) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      tab[vertex] = -2;
      for (final connectedVertex in _edges[vertex] ?? <T>{}) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      // We tried all options.
      tab[vertex] = -3;
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
    for (final vertex in vertices.reversed) {
      if (isCyclic) break;
      visit(vertex);
    }

    // Return null if graph is not a DAG.
    return (isCyclic) ? null : queue.toList();
  }

  /// Returns the first cycle detected or an empty list
  /// if the graph is acyclic.
  ///
  /// Note: A cycle is a path that starts and ends with
  /// the same vertex.
  List<T> get cycle {
    // Start vertex of the cycle.
    T? start;

    final temp = <T>{};
    final perm = <T>{};

    // Marks [this] graph as acyclic.
    var isCyclic = false;

    // Recursive function
    void visit(T vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // _Vertex has permanent mark.
      // => This vertex and its neighbouring vertices have already been visited.
      if (perm.contains(vertex)) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (temp.contains(vertex)) {
        start = vertex;
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      temp.add(vertex);
      for (final connected_Vertex in _edges[vertex] ?? <T>{}) {
        visit(connected_Vertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      perm.add(vertex);
    }

    // Main loop
    for (final vertex in _edges.keys) {
      if (isCyclic) break;
      visit(vertex);
    }

    final crawler = GraphCrawler<T>(edges);

    // Find cycle path.
    return isCyclic ? crawler.path(start!, start!) : [];
  }

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<T, int> get outDegreeMap {
    final map = <T, int>{};
    for (final vertex in _edges.keys) {
      map[vertex] = _edges[vertex]!.length;
    }
    return map;
  }

  /// Returns the number of incoming directed edges for [vertex].
  int? outDegree(T vertex) {
    return _edges[vertex]?.length;
  }

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<T, int> get inDegreeMap {
    var map = <T, int>{};
    for (final vertex in _edges.keys) {
      // Entry might already exist.
      map[vertex] ??= 0;
      for (final connectedVertex in _edges[vertex] ?? <T>{}) {
        map[connectedVertex] =
            (map[connectedVertex] == null) ? 1 : map[connectedVertex]! + 1;
      }
    }
    return map;
  }

  /// Returns the number of incoming directed edges for [vertex].
  int inDegree(T vertex) {
    var inDegree = 0;
    for (final connectedVertices in _edges.values) {
      inDegree =
          inDegree + connectedVertices.where((item) => item == vertex).length;
    }
    return inDegree;
  }

  /// Returns a string representation of the graph.
  @override
  String toString() {
    var b = StringBuffer();
    b.writeln('{');
    for (final vertex in vertices) {
      b.write(' $vertex: ');
      b.write('[');
      b.writeAll(_edges[vertex]!, ', ');
      b.write('],');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }

  @override
  Iterator<T> get iterator => vertices.iterator;
}
