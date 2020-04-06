import 'dart:collection' show UnmodifiableListView;

import 'package:graphs/graphs.dart' as graphs;
import 'package:directed_graph/src/vertex.dart';
import 'package:lazy_evaluation/lazy_evaluation.dart';

/// Generic directed graph.
/// Data of type [T] is stored in vertices of type [Vertex<T>].
/// The graph consists of a mapping [_edges] of each
/// [Vertex<T>] to a list of connected vertices [List<Vertex<T>>].
class DirectedGraph<T> extends Iterable{
  Map<Vertex<T>, List<Vertex<T>>> _edges;
  MutableLazy<UnmodifiableListView<Vertex<T>>> _vertices;
  Map<Vertex<T>, int> _inDegreeMap;
  Comparator<Vertex<T>> comparator;

  /// Constructs a directed graph.
  /// [edges] is of type [Map<Vertex<T>, List<Vertex<T>>>],
  /// mapping each vertex to a list of connected vertices.
  DirectedGraph(
    Map<Vertex<T>, List<Vertex<T>>> edges, {
    this.comparator,
  }) : _edges = edges ?? {} {
    _inDegreeMap = calculateInDegreeMap();
    _vertices = MutableLazy<UnmodifiableListView<Vertex<T>>>(_sortedVertices);
  }

  /// Constructs a directed graph from another directed graph.
  DirectedGraph.from(DirectedGraph<T> directedGraph)
      : this(directedGraph._edges, comparator: directedGraph.comparator);

  /// Sorts vertices using the comparator provided during graph construction.
  UnmodifiableListView<Vertex<T>> _sortedVertices() {
    var vertices = _inDegreeMap.keys.toList();
    if (comparator != null) vertices.sort(comparator);
    return UnmodifiableListView(vertices);
  }

  /// Mapping [Vertex<T>] to a list of connected vertices [List<Vertex<T>>].
  Map<Vertex<T>, List<Vertex<T>>> get edgeMap => _edges;

  /// Returns a list of the connected vertices of [vertex].
  /// Note: Mathematically, an edge is an ordered pair (vertex, connected-vertex).
  List<Vertex<T>> edges(Vertex<T> vertex) => _edges[vertex] ?? [];

  /// Unmodifiable ListView of all vertices in the graph.
  /// The vertices will be sorted if a vertex comparator was
  /// specified when creating the graph.
  UnmodifiableListView<Vertex<T>> get vertices => _vertices.value;

  /// Returns a (modifiable) copy of the inDegreeMap.
  Map<Vertex<T>, int> get inDegreeMap => Map<Vertex<T>, int>.from(_inDegreeMap);

  /// Adds edges (connections) pointing from [vertex] to [connectedVertices].
  /// If the graph does not contain [vertex] it will be added.
  void addEdges(Vertex<T> vertex, List<Vertex<T>> connectedVertices) {
    // Check if vertex exists.
    if (_edges[vertex] == null) {
      _edges[vertex] = connectedVertices;
    } else {
      _edges[vertex].addAll(connectedVertices);
    }
    // Update inDegreeMap
    for (final connectedVertex in connectedVertices) {
      _inDegreeMap[connectedVertex] = (_inDegreeMap[connectedVertex] == null)
          ? 1
          : _inDegreeMap[connectedVertex] + 1;
    }
    // Check if [vertex] is new to the graph.
    if (_inDegreeMap[vertex] == null) {
      _inDegreeMap[vertex] = 0;
    }
    // Update lazy fields
    _updateLazyFields();
  }

  /// Removes edges (connections) pointing from [vertex] to [connectedVertices].
  /// If connectedVertices is not specified all outgoing edges are removed from the graph.
  void removeEdges(Vertex<T> vertex,
      [List<Vertex<T>> connectedVertices = const []]) {
    // Handle default case: Remove all outgoing edges if connectedVertices is empty.
    if (connectedVertices.isEmpty) {
      // Update inDegreeMap.
      for (final connectedVertex in _edges[vertex]) {
        _inDegreeMap[connectedVertex] -= 1;
      }
      _edges.remove(vertex);
    } else {
      // Remove only specified outgoing edges.
      _edges[vertex].removeWhere(
        (connectedVertex) => connectedVertices.contains(connectedVertex),
      );
      // Update inDegreeMap.
      for (final connectedVertex in connectedVertices) {
        _inDegreeMap[connectedVertex] -= 1;
      }
      if (_edges[vertex].isEmpty) {
        _edges.remove(vertex);
      }
    }
    _updateLazyFields();
  }

  /// Removes edges ending at [vertex] from the graph.
  void removeIncomingEdges(Vertex<T> vertex) {
    // Remove incoming edges
    for (final startVertex in _edges.keys ?? []) {
      _edges[startVertex].removeWhere((item) => item == vertex);
    }
  }

  /// Completely remove [vertex] from the graph, including outgoing and incoming edges.
  void remove(Vertex<T> vertex) {
    removeIncomingEdges(vertex);
    _inDegreeMap.remove(vertex);
    removeEdges(vertex);
  }

  /// Returns a valid reverse topological order ordering of the strongly connected components.
  /// Acyclic graphs will yield components containing one vertex only.
  List<List<Vertex<T>>> stronglyConnectedComponents() {
    return graphs.stronglyConnectedComponents<Vertex<T>>(_edges.keys, edges);
  }

  /// Returns the shortest path between [start] and [target].
  /// Returns [null] if [start] is not connected to [target].
  List<Vertex<T>> shortestPath(Vertex<T> start, Vertex<T> target) {
    return graphs.shortestPath<Vertex<T>>(start, target, edges);
  }

  /// Returns true if the graph is a directed acyclic graph.
  bool isAcyclic() {
    return (topologicalOrdering() == null) ? false : true;
  }

  /// Returns a list of type [List<List<Vertex<T>>>].
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
  /// graph is cyclic. In that case the function returns [null].
  List<List<Vertex<T>>> localSources() {
    List<List<Vertex<T>>> result = [];

    // Get modifiable in-degree map.
    final inDegreeMap = this.inDegreeMap;
    final vertices = List.from(inDegreeMap.keys);

    bool hasSources = false;
    int count = 0;

    // Note: In an acyclic directed graph at least one vertex has outDegree zero.
    do {
      // Storing local sources.
      final List<Vertex<T>> sources = [];

      // Storing locations of local sources.
      final List<int> locations = [];

      // Find sources and their locations.
      for (var i = 0; i < vertices.length; i++) {
        if (inDegreeMap[vertices[i]] == 0) {
          sources.add(vertices[i]);
          locations.add(i);
          ++count;
        }
      }
      // for (final vertex in vertices ?? []) {
      //   if (inDegreeMap[vertex] == 0) {
      //     sources.add(vertex);
      //     ++count;
      //   }
      // }

      // Add sources to result:
      if (sources.isNotEmpty) result.add(sources);

      // Remove local sources from list of vertices.
      // Note: This method is slightly more efficient compared to
      // the code line below:
      // vertices.removeWhere((item) => inDegreeMap[item] == 0);
      for (var i = 0; i < locations.length; i++) {
        vertices.removeAt(locations[i] - i);
      }

      // Simulate the removal of detected local sources.
      for (var source in sources) {
        for (final connectedVertex in _edges[source] ?? []) {
          inDegreeMap[connectedVertex] -= 1;
        }
      }
      // Check if local source were found.
      hasSources = sources.isNotEmpty;
    } while (hasSources);

    return (count == this.inDegreeMap.keys.length) ? result : null;
  }

  /// Returns [List<Vertex<T>>], a list of all vertices in topological order.
  /// For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns [null].
  /// Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// Based on Kahn's algorithm.
  List<Vertex<T>> topologicalOrdering([Comparator<Vertex<T>> comparator]) {
    List<Vertex<T>> result = [];

    // Get modifiable in-degree map.
    final inDegreeMap = this.inDegreeMap;

    // Add all sources (vertices with inDegree == 0) to queue.
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    List<Vertex<T>> sources = [];
    for (final vertex in this.vertices) {
      if (inDegreeMap[vertex] == 0) {
        sources.add(vertex);
      }
    }

    // Initialize count of visited vertices.
    int count = 0;

    // Note: In an acyclic directed graph at least one vertex has outDegree zero.
    while (sources.isNotEmpty) {
      // Sort source vertices:
      if (comparator != null) sources.sort(comparator);
      var current = sources.removeAt(0);
      result.add(current);

      // Simulate removing the current vertex from the
      //   graph. => Connected vertices with have inDegree = inDegree - 1.
      for (final vertex in _edges[current] ?? []) {
        inDegreeMap[vertex] -= 1;

        // Add new source vertices of the remaining graph to the queue.
        if (inDegreeMap[vertex] == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }
    return (count != vertices.length) ? null : result;
  }

  /// Returns [List<Vertex<T>>], a list of all vertices in topological order.
  /// For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns [null].
  /// Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// Based on a depth-first search algorithm (Cormen 2001, Tarjan 1976).
  List<Vertex<T>> topologicalOrderingDFS() {
    final List<Vertex<T>> result = [];

    /// Add all nodes to queue.
    List<Vertex<T>> vertices = List.from(this.vertices);

    // Map keeping a tab on visited vertices.
    //     1 => temporary mark.
    //     2 => permanent mark.
    Map<Vertex<T>, int> tab = {};

    // Marks [this] graph as cyclic.
    bool isCyclic = false;

    // Recursive function
    void visit(Vertex<T> vertex) {
      /// Graph is not a Directed Acyclic Graph (DAG).
      /// Terminate iteration.
      if (isCyclic) return;

      /// Vertex has permanent mark.
      /// => This vertex and its neighbouring vertices have already been visited.
      if (tab[vertex] == 2) return;

      /// A cycle has been detected. Mark graph as acyclic.
      if (tab[vertex] == 1) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      tab[vertex] = 1;
      for (var connectedVertex in _edges[vertex] ?? []) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      tab[vertex] = 2;
      result.insert(0, vertex);
    }

    // Main loop
    for (var current in vertices.reversed) {
      if (isCyclic) break;
      visit(current);
    }
    // Return null if graph is not a DAG.
    return (isCyclic) ? null : result;
  }

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<Vertex<T>, int> calculateInDegreeMap() {
    var map = Map<Vertex<T>, int>();
    for (final vertex in _edges.keys) {
      // Entry might already exist.
      map[vertex] ??= 0;
      for (final connectedVertex in _edges[vertex]) {
        map[connectedVertex] =
            (map[connectedVertex] == null) ? 1 : map[connectedVertex] + 1;
      }
    }
    return map;
  }

  /// Returns the number of incoming directed edges for [vertex].
  int inDegree(Vertex<T> vertex) {
    int inDegree = 0;
    for (final connectedVertices in _edges.values) {
      inDegree =
          inDegree + connectedVertices.where((value) => value == vertex).length;
    }
    return inDegree;
  }

  /// Returns the number of outgoing directed edges for [vertex].
  int outDegree(Vertex<T> vertex) {
    return _edges[vertex]?.length ?? 0;
  }

  /// Returns a mapping between vertex and number of
  /// outgoing connections (edges).
  Map<Vertex<T>, int> outDegreeMap() {
    var map = Map<Vertex<T>, int>();
    for (var vertex in vertices) {
      map[vertex] = _edges[vertex]?.length ?? 0;
    }
    return map;
  }

  /// Returns a string representation of the graph.
  @override
  String toString() {
    var b = StringBuffer();
    b.writeln('{');
    for (var vertex in _vertices.value) {
      b.write(' $vertex: ');
      b.write('[');
      b.writeAll(_edges[vertex] ?? [], ', ');
      b.write('],');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }

  /// Call this method whenever vertices or edges are added to the graph.
  _updateLazyFields() {
    _vertices.notifyChange();
  }

  @override
  Iterator get iterator => _vertices.value.iterator;
}
