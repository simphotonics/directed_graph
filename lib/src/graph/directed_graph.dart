import '../extensions/sort.dart';
import 'directed_graph_base.dart';

/// Generic directed graph storing vertices of type [T].
/// The type [T] should be usable as a map key.
class DirectedGraph<T extends Object> extends DirectedGraphBase<T> {
  /// Graph edges.
  /// * Each graph vertex corresponds to a map key.
  final Map<T, Set<T>> _edges = {};

  /// Constructs a directed graph.
  /// * [edges]: a map of type `Map<T, Set<T>>`,
  /// * [comparator]
  /// : a function with typedef [Comparator] and type
  /// parameter [T] used to sort the graph vertices.
  new(Map<T, Set<T>> edges, {Comparator<T>? comparator}) : super(comparator) {
    edges.forEach((vertex, connectedVertices) {
      _edges[vertex] = Set<T>.of(connectedVertices);
      for (final connectedVertex in connectedVertices) {
        _edges[connectedVertex] ??= <T>{};
      }
    });
  }

  /// Constructs a directed graph from a map of weighted edges.
  new fromWeightedEdges(
    Map<T, Map<T, Object>> weightedEdges, {
    Comparator<T>? comparator,
  }) : super(comparator) {
    weightedEdges.forEach((vertex, connectedVerticeWeights) {
      _edges[vertex] = Set<T>.of(connectedVerticeWeights.keys);
      for (final connectedVertex in connectedVerticeWeights.keys) {
        _edges[connectedVertex] ??= <T>{};
      }
    });
  }

  /// Constructs a shallow copy of [graph].
  new of(DirectedGraph<T> graph)
    : this(graph.data, comparator: graph.comparator);

  /// Factory constructor returning the transitive closure of [graph].
  factory transitiveClosure(DirectedGraph<T> graph) {
    final tcEdges = <T, Set<T>>{};
    for (final root in graph) {
      tcEdges[root] = graph.crawler.reachableVertices(root);
    }
    return DirectedGraph(tcEdges, comparator: graph.comparator);
  }

  /// Constructs an instance of [UnmodifiableDirectedGraph].
  factory unmodifiable(Map<T, Set<T>> edges, {Comparator<T>? comparator}) {
    return UnmodifiableDirectedGraph(edges, comparator: comparator);
  }

  /// Returns a copy of the graph edges
  /// as a map of type `Map<T, Set<T>>`.
  Map<T, Set<T>> get data {
    final data = <T, Set<T>>{};
    for (final vertex in sortedVertices) {
      data[vertex] = _edges[vertex]!;
    }
    return data;
  }

  @override
  Iterator<T> get iterator => vertices.iterator;

  @override
  T get last => _edges.keys.last;

  @override
  int get length => _edges.length;

  /// Returns a list of all vertices.
  /// * The vertices are sorted if a comparator was specified.
  @override
  Iterable<T> get vertices => _edges.keys;

  /// Adds a new edge pointing from [vertex] to [connectedVertex].
  ///
  /// If [vertex] or [connectedVertex] are new, then they are
  /// added to the graph.
  void addEdge(T vertex, T connectedVertex) {
    if (_edges.containsKey(vertex)) {
      _edges[vertex]!.add(connectedVertex);
    } else {
      _edges[vertex] = {connectedVertex};
    }
    // If connectedVertex is new add it to the graph.
    _edges[connectedVertex] ??= <T>{};
    updateCache();
  }

  /// Adds edges (connections) pointing from [vertex] to [connectedVertices].
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

  @override
  bool contains(Object? element) => _edges.containsKey(element);

  @override
  bool edgeExists(T vertex, T connectedVertex) {
    if (_edges.containsKey(vertex) &&
        _edges[vertex]!.contains(connectedVertex)) {
      return true;
    }
    return false;
  }

  /// Returns the vertices connected to [vertex].
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  @override
  Set<T> edges(T vertex) => _edges[vertex] ?? <T>{};

  /// Completely removes [vertex] from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    if (_edges.containsKey(vertex)) {
      removeIncomingEdges(vertex);
      _edges.remove(vertex);
      updateCache();
    }
  }

  /// Removes the edge pointing from [vertex] to [connectedVertex].
  /// Does not remove the vertices.
  void removeEdge(T vertex, T connectedVertex) {
    _edges[vertex]?.remove(connectedVertex);
  }

  /// Removes edges (connections) pointing from [vertex] to [connectedVertices].
  /// Note: Does not remove the vertices.
  void removeEdges(T vertex, Set<T> connectedVertices) {
    _edges[vertex]?.removeAll(connectedVertices);
    updateCache();
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

  /// Sorts the graph vertices using [comparator] and then calls
  /// [sortEdges].
  /// * Without sorting the graph vertices are listed in insertion order.
  /// * Note: In general, adding further vertices and graph edges invalidates
  /// the sorting.
  void sort() {
    if (!hasComparator) return;
    _edges.sortByKey(comparator);
    for (final vertex in vertices) {
      _edges[vertex]?.sort(comparator);
    }
  }

  /// Sorts the neighbouring vertices of each vertex using [comparator].
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  ///   ```
  ///   graph.addEdges(a, {d, b, c}); // graph.edges(a): {d, b, c}
  ///   graph.sortEdges();            // graph.edges(a): {b, c, d}
  ///   ```
  /// * Note: In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  void sortEdges() {
    if (!hasComparator) return;
    for (final vertex in vertices) {
      _edges[vertex]?.sort(comparator);
    }
  }

  @override
  bool vertexExists(T vertex) {
    return _edges.containsKey(vertex);
  }
}

/// An unmodifiable [DirectedGraph].
final class UnmodifiableDirectedGraph<T extends Object>
    extends DirectedGraph<T> {
  /// Constructs an unmodifiable directed graph from [edges].
  new(super.edges, {super.comparator});

  /// Constructs an unmodifiable directed graph from [graph].
  new of(DirectedGraph<T> graph)
    : this(graph.data, comparator: graph.comparator);

  /// Adds edges to [graph] and constructs an unmodifiable directed graph.
  ///
  /// Note: If a vertex w is reachable from v and there is no edge (v,w) then
  /// this edge is added prior to constructing the graph.
  factory transitiveClosure(DirectedGraph<T> graph) {
    final tcEdges = <T, Set<T>>{};
    for (final root in graph) {
      tcEdges[root] = graph.crawler.reachableVertices(root);
    }

    return UnmodifiableDirectedGraph(tcEdges, comparator: graph.comparator);
  }

  /// Cannot a edges to an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void addEdge(T vertex, T connectedVertex) {
    throw UnsupportedError('Cannot add edges to an unmodifiable graph');
  }

  /// Cannot add edges to an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void addEdges(T vertex, Set<T> connectedVertices) {
    throw UnsupportedError('Cannot add edges to an unmodifiable graph');
  }

  /// Cannot clear an [UnmodifiableDirectedGraph].
  ///
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void clear() {
    throw UnsupportedError('Cannot clear an unmodifiable graph');
  }

  /// Cannot clear edges of an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void clearEdges() {
    throw UnsupportedError('Cannot clear the edges of an unmodifiable graph');
  }

  /// Cannot set the [Comparator] of an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  set comparator(Comparator<T>? comparator) {
    throw UnsupportedError(
      'Cannot set the comparator of an unmodifiable graph',
    );
  }

  /// Cannot remove vertices from an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void remove(T vertex) {
    throw UnsupportedError('Cannot remove vertices from an unmodifiable graph');
  }

  /// Cannot remove edges of an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void removeEdge(T vertex, T connectedVertex) {
    throw UnsupportedError('Cannot remove edges from an unmodifiable graph');
  }

  /// Cannot remove edges of an[UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void removeEdges(T vertex, Set<T> connectedVertices) {
    throw UnsupportedError('Cannot remove edges from an unmodifiable graph');
  }

  /// Cannot remove edges of an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void removeIncomingEdges(T vertex) {
    throw UnsupportedError('Cannot remove edges from an unmodifiable graph');
  }

  /// Cannot sort an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void sort() {
    throw UnsupportedError('Cannot sort an unmodifiable graph');
  }

  /// Cannot sort the edges of an [UnmodifiableDirectedGraph].
  ///
  /// Throws an error of type [UnsupportedError].
  @override
  void sortEdges() {
    throw UnsupportedError('Cannot sort the edges of an unmodifiable graph');
  }
}
