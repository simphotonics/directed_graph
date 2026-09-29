import 'package:directed_graph/src/extensions/edge_count.dart';
import 'package:directed_graph/src/graph/directed_graph_base.dart';

import '../extensions/sort.dart' show SortMap;

/// A directed graph storing vertices of type [T].
/// * Each graph edge has an [edgeCount], a positive integer.
/// * Adding an edge increases its [edgeCount].
/// * Removing an edge decreases its [edgeCount].
/// * The identitiy of an edge is determined by an ordered vertex pair. Multiple
///   edges defined by the same ordered vertex pair do not have a separate
///   identity.
class DirectedMultiGraph<T extends Object> extends DirectedGraphBase<T> {
  /// Stores the graph edges.
  /// Each graph vertex corresponds to a map key.
  final Map<T, Map<T, int>> _edges = {};

  /// Constructs a directed graph with vertices of type [T]
  /// and associates each graph edge with a positive integer, the edge
  /// count.
  /// * [edges]: The edges of the graph, including a (positive) edge count.
  /// * [comparator]: An (optional) comparator function.
  /// * Note: Edges with an edge count smaller than 1 will not be added to the
  /// graph. However, the vertices will be added to the graph.
  new(Map<T, Map<T, int>> edges, {Comparator<T>? comparator})
    : super(comparator) {
    edges.forEach((vertex, connectedVerticeEdgeCounts) {
      _edges[vertex] = Map.of(connectedVerticeEdgeCounts)
        ..removeWhere((_, count) => count < 1);
      // Add connected vertices to the graph.
      for (final connectedVertex in connectedVerticeEdgeCounts.keys) {
        _edges[connectedVertex] ??= <T, int>{};
      }
    });
  }

  /// Constructs an emtpy [DirectedMultiGraph].
  new empty({Comparator<T>? comparator}) : super(comparator);

  /// Constructs a shallow copy of [graph].
  new of(DirectedMultiGraph<T> graph, {Comparator<T>? comparator})
    : this(graph.data, comparator: graph.comparator);

  /// Factory constructor returning the transitive closure of [graph].
  factory transitiveClosure(DirectedMultiGraph<T> graph) {
    final tcEdges = <T, Map<T, int>>{};
    for (final vertex in graph) {
      final connectedVertices = graph.crawler.reachableVertices(vertex);

      tcEdges[vertex] = {
        for (final connectedVertex in connectedVertices)
          connectedVertex: graph.edgeCount(vertex, connectedVertex) == 0
              ? 1
              : graph.edgeCount(vertex, connectedVertex),
      };
    }
    return DirectedMultiGraph(tcEdges, comparator: graph.comparator);
  }

  /// Returns a copy of the weighted edges
  /// as an object of type `Map<T, Map<T, W>>`.
  Map<T, Map<T, int>> get data {
    final out = <T, Map<T, int>>{};
    for (final vertex in sortedVertices) {
      out[vertex] = Map.of(_edges[vertex]!);
    }
    return out;
  }

  @override
  Iterator<T> get iterator => _edges.keys.iterator;

  @override
  Iterable<T> get vertices => _edges.keys;

  /// Adds a new edge pointing from [vertex] to [connectedVertex].
  ///
  /// If the edge ([vertex], [connectedVertex]) exists,
  /// the edge count is incremented.
  void addEdge(T vertex, T connectedVertex) {
    if (_edges.containsKey(vertex)) {
      _edges[vertex]!.increment(connectedVertex);
    } else {
      _edges[vertex] = {connectedVertex: 1};
    }
    // Add any new vertices to the graph:
    _edges[connectedVertex] ??= <T, int>{};
    updateCache();
  }

  /// Adds weighted edges pointing from [vertex] to the vertices specified as
  /// the keys of the map [vertices].
  void addEdges(T vertex, List<T> vertices) {
    if (_edges[vertex] == null) {
      // If vertex is new add it to the graph.
      _edges[vertex] = {for (var e in vertices) e: 1};
    } else {
      for (final connectedVertex in vertices) {
        _edges[vertex]?.increment(connectedVertex);
      }
    }

    /// Add any newly added vertices to the graph.
    for (final connectedVertex in vertices) {
      _edges[connectedVertex] ??= <T, int>{};
    }
    updateCache();
  }

  @override
  void clear() {
    _edges.clear();
    updateCache();
  }

  @override
  void clearEdges() {
    for (final vertex in _edges.keys) {
      _edges[vertex]!.clear();
    }
    updateCache();
  }

  /// Returns the edge count of the edge (vertex, connectedVertex).
  /// * Returns 0 if [vertex] is not belonging to the graph.
  /// * Returns 0 if there is no edge (vertex, connectedVertex).
  int edgeCount(T vertex, T connectedVertex) =>
      _edges[vertex]?[connectedVertex] ?? 0;

  @override
  bool edgeExists(T vertex, T connectedVertex) {
    return _edges[vertex]?.containsKey(connectedVertex) ?? false;
  }

  @override
  Set<T> edges(T vertex) => _edges[vertex]?.keys.toSet() ?? <T>{};

  /// Completely removes [vertex] from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    if (_edges.containsKey(vertex)) {
      removeIncomingEdges(vertex);
      _edges.remove(vertex);
      updateCache();
    }
  }

  /// Removes edges ending at [vertex] from the graph.
  void removeIncomingEdges(T vertex) {
    if (_edges.containsKey(vertex)) {
      for (final connectedVertices in _edges.values) {
        connectedVertices.remove(vertex);
      }
      updateCache();
    }
  }

  /// Removes *one* edge pointing from [vertex] to [connectedVertex] and
  /// decrements the edge count.
  /// Does not remove any vertices from the graph.
  void removeEdge(T vertex, T connectedVertex) {
    _edges[vertex]?.decrement(connectedVertex);
    updateCache();
  }

  /// Removes edges pointing from [vertex] to [connectedVertices].
  ///
  /// Does not remove any vertices from the graph.
  void removeEdges(T vertex, List<T> connectedVertices) {
    // Return early if vertex does not belong to the graph.
    if (!_edges.containsKey(vertex)) return;
    for (final connectedVertex in connectedVertices) {
      _edges[vertex]!.decrement(connectedVertex);
    }
    updateCache();
  }

  /// Sorts the graph vertices using [comparator] and then calls
  /// [sortEdges].
  /// * Without sorting, the graph vertices are listed in insertion order.
  /// * Note: In general, adding further vertices and graph edges invalidates
  /// the sorting.
  void sort() {
    if (comparator == null) return;
    _edges.sortByKey(comparator);
    sortEdges();
  }

  /// Sorts the neighbouring vertices of each vertex using [comparator].
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  /// * In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  void sortEdges() {
    if (comparator == null) return;
    for (final vertex in vertices) {
      _edges[vertex]!.sortByKey(comparator);
    }
  }

  @override
  bool vertexExists(T vertex) => _edges.containsKey(vertex);

  @override
  String toString() {
    var b = StringBuffer();
    final q = (T == String) ? '\'' : '';

    b.writeln('{');
    for (final vertex in sortedVertices) {
      b.write(' $q$vertex$q: ');
      b.write('{');
      b.writeAll(
        _edges[vertex]!.keys.map<String>(
          (key) => '$q$key$q: ${_edges[vertex]![key]}',
        ),
        ', ',
      );

      b.write('},');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }
}
