import 'directed_graph_base.dart';
import '../extensions/sort.dart';

/// Generic directed graph storing vertices of type `T`.
///
/// The data-type `T` should be usable as a map key.
class DirectedGraph<T extends Object> extends DirectedGraphBase<T> {
  /// Constructs a directed graph.
  /// * `edges`: a map of type `Map<T, Set<T>>`,
  /// * `comparator`: a function with typedef `Comparator<T>` used to sort
  /// the graph vertices.
  DirectedGraph(
    Map<T, Set<T>> edges, {
    Comparator<T>? comparator,
  }) : super(comparator) {
    edges.forEach((vertex, connectedVertices) {
      _edges[vertex] = Set<T>.of(connectedVertices);
      for (final connectedVertex in connectedVertices) {
        _edges[connectedVertex] ??= <T>{};
      }
    });
  }

  /// Constructs a shallow copy of `graph`.
  DirectedGraph.of(DirectedGraph<T> graph)
      : this(
          graph.data,
          comparator: graph.comparator,
        );

  /// Constructs a directed graph from a map of weighted edges.
  DirectedGraph.fromWeightedEdges(Map<T, Map<T, dynamic>> weightedEdges,
      {Comparator<T>? comparator})
      : super(comparator) {
    weightedEdges.forEach((vertex, connectedVerticeWeights) {
      _edges[vertex] = Set<T>.of(connectedVerticeWeights.keys);
      for (final connectedVertex in connectedVerticeWeights.keys) {
        _edges[connectedVertex] ??= <T>{};
      }
    });
  }

  /// Factory constructor returning the transitive closure of [graph].
  factory DirectedGraph.transitiveClosure(DirectedGraph<T> graph) {
    final tcEdges = <T, Set<T>>{};
    void addReachableVertices(T root, T current) {
      for (final vertex in graph.edges(current)) {
        if (tcEdges[root]!.contains(vertex)) continue;
        tcEdges[root]!.add(vertex);
        addReachableVertices(root, vertex);
      }
    }

    for (final root in graph) {
      tcEdges[root] = <T>{};
      addReachableVertices(root, root);
    }
    return DirectedGraph(tcEdges, comparator: graph.comparator);
  }

  /// Graph edges.
  /// * Each graph vertex corresponds to a map key.
  final Map<T, Set<T>> _edges = {};

  /// Returns a list of all vertices.
  /// * The vertices are sorted if a comparator was specified.
  @override
  Iterable<T> get vertices => _edges.keys;

  /// Returns a copy of the graph edges
  /// as a map of type `Map<T, Set<T>>`.
  Map<T, Set<T>> get data {
    final data = <T, Set<T>>{};
    for (final vertex in sortedVertices) {
      data[vertex] = _edges[vertex]!;
    }
    return data;
  }

  /// Returns the vertices connected to `vertex`.
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  @override
  Iterable<T> edges(T vertex) => _edges[vertex] ?? <T>{};

  /// Adds edges (connections) pointing from `vertex` to `connectedVertices`.
  void addEdges(T vertex, Set<T> connectedVertices) {
    if (_edges.containsKey(vertex)) {
      _edges[vertex]!.addAll(connectedVertices);
    } else {
      // If vertex is new add it to the graph.
      _edges[vertex] = Set.of(connectedVertices);
    }
    for (final connectedVertex in connectedVertices) {
      // If connectedVertex is new add it to the graph.
      _edges[connectedVertex] ??= <T>{};
    }
    updateCache();
  }

  /// Removes edges (connections) pointing from `vertex` to `connectedVertices`.
  /// * Note: Does not remove the vertices.
  void removeEdges(T vertex, Set<T> connectedVertices) {
    _edges[vertex]?.removeAll(connectedVertices);
    updateCache();
  }

  /// Removes edges ending at `vertex` from the graph.
  void removeIncomingEdges(T vertex) {
    if (_edges.containsKey(vertex)) {
      for (final connectedVertices in _edges.values) {
        connectedVertices.remove(vertex);
      }
      updateCache();
    }
  }

  /// Completely removes `vertex` from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    if (_edges.containsKey(vertex)) {
      removeIncomingEdges(vertex);
      _edges.remove(vertex);
      updateCache();
    }
  }

  /// Removes all graph edges.
  void clear() {
    _edges.clear();
    updateCache();
  }

  /// Sorts the neighbouring vertices of each vertex using `comparator`.
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  ///   ```
  ///   graph.addEdges(a, {d, b, c}); // graph.edges(a): {d, b, c}
  ///   graph.sortEdges();            // graph.edges(a): {b, c, d}
  ///   ```
  /// * Note: In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  void sortEdges() {
    if (comparator == null) return;
    for (final vertex in vertices) {
      _edges[vertex]!.sort(comparator!);
    }
  }

  @override
  Iterator<T> get iterator => vertices.iterator;
}
