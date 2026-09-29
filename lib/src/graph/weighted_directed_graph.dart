import 'package:exception_templates/exception_templates.dart';
import 'package:lazy_memo/lazy_memo.dart';

import '../exceptions/error_types.dart';
import '../extensions/sort.dart';
import 'directed_graph_base.dart';

/// A directed graph storing vertices of type [T]. A weight of type
/// [W] is associated with each directed edge. Note:
/// [T] must be usable as a map key.
class WeightedDirectedGraph<T extends Object, W extends Comparable>
    extends DirectedGraphBase<T> {
  /// The weight of an empty path.
  /// * Used as the initial value when summing the weight of a path.
  /// * Represents the additive identity of type [W].
  /// * Has the property: `(w + zero) == w`, where `w` and `zero` are of type
  ///   [W].
  /// * Examples: `int: 0`, `double: 0.0`, `String: ''`.
  final W zero;

  /// Stores the graph edges.
  /// Each graph vertex corresponds to a map key.
  final Map<T, Map<T, W>> _edges = {};

  /// Function used to sum edge weights.
  final Summation<W> summation;

  /// Lazy variable representing the graph weight.
  late final _weight = Lazy<W>(() {
    var sum = zero;
    for (final vertex in vertices) {
      var partialSum = zero;
      // Adding weight of edges connected to vertex.
      for (final weight in _edges[vertex]!.values) {
        partialSum = summation(partialSum, weight);
      }
      sum = summation(sum, partialSum);
    }
    return sum;
  });

  /// Constructs a weighted directed graph with vertices of type [T]
  /// and associates to each graph edge a weight of type [W].
  /// * [edges]: The weighted edges of the graph. An empty map may
  /// be used to create an empty graph.
  /// * [zero]: The weight of an empty path. It represents the additive
  /// identity of the type [W].
  /// * [summation]: The function used to sum edge weights.
  /// * Note: [W] must extend [Comparable].
  new(
    Map<T, Map<T, W>> edges, {
    required this.summation,
    required this.zero,
    Comparator<T>? comparator,
    Comparator<W>? weightComparator,
  }) : weightComparator = weightComparator ?? defaultWeightComparator,
       super(comparator) {
    edges.forEach((vertex, connectedVerticeWeights) {
      _edges[vertex] = Map.of(connectedVerticeWeights);
      for (final connectedVertex in connectedVerticeWeights.keys) {
        _edges[connectedVertex] ??= <T, W>{};
      }
    });
  }

  /// Constructs a shallow copy of [graph].
  new of(WeightedDirectedGraph<T, W> graph)
    : this(
        graph.data,
        summation: graph.summation,
        zero: graph.zero,
        comparator: graph.comparator,
        weightComparator: graph.weightComparator,
      );

  /// Constructs the transitive closure of [graph].
  factory transitiveClosure(WeightedDirectedGraph<T, W> graph) =>
      WeightedDirectedGraph(
        graph.transitiveWeightedEdges,
        comparator: graph.comparator,
        weightComparator: graph.weightComparator,
        summation: graph.summation,
        zero: graph.zero,
      );

  /// Returns a copy of the weighted edges
  /// as an object of type `Map<T, Map<T, W>>`.
  Map<T, Map<T, W>> get data {
    final out = <T, Map<T, W>>{};
    for (final vertex in sortedVertices) {
      out[vertex] = Map.of(_edges[vertex]!);
    }
    return out;
  }

  @override
  Iterator<T> get iterator => vertices.iterator;

  @override
  T get last => _edges.keys.last;

  @override
  int get length => _edges.keys.length;

  /// Returns the weighted edges representing the
  /// transitive closure of `this`.
  Map<T, Map<T, W>> get transitiveWeightedEdges {
    final tcEdges = <T, Map<T, W>>{};
    for (final vertex in vertices) {
      // Add direct edges
      tcEdges.addAll({vertex: _edges[vertex] ?? {}});
      // All vertices reachable from vertex.
      final reachableVertices = crawler.reachableVertices(vertex);

      for (final reachableVertex in reachableVertices) {
        if (tcEdges[vertex]!.containsKey(reachableVertex)) {
          // Don't add another entry. There is already a direct edge
          // (vertex,reachableVertex).
          continue;
        }
        // Calculate smallest weight of path linking vertex to connectedVertex.
        tcEdges[vertex]?.addAll({
          reachableVertex: lightestPath(vertex, reachableVertex).weight,
        });
      }
    }
    return tcEdges;
  }

  /// Returns a list of all vertices.
  ///
  /// To retrieve a list of sorted vertices use the getter [sortedVertices].
  @override
  Iterable<T> get vertices => _edges.keys;

  /// The comparator used to sort edge weights.
  /// This field holds either:
  /// * the comparator provided as constructor parameter,
  /// * the comparator set by the user,
  /// * the default comparator.
  Comparator<W> weightComparator;

  /// Returns the inverse of [weightComparator].
  Comparator<W> get inverseWeigthComparator =>
      (W left, W right) => -weightComparator(left, right);

  /// Returns the sum of all graph edges.
  W get weight => _weight();

  /// Adds a new weighted edge pointing from [vertex] to [connectedVertex].
  ///
  /// If the edge ([vertex], [connectedVertex]) exists,
  /// the edge [weight] is updated.
  void addEdge(T vertex, T connectedVertex, W weight) {
    if (_edges.containsKey(vertex)) {
      _edges[vertex]![connectedVertex] = weight;
    } else {
      _edges[vertex] = {connectedVertex: weight};
    }
    // Add any new vertices to the graph:
    _edges[connectedVertex] ??= <T, W>{};
    updateCache();
  }

  /// Adds weighted edges pointing from [vertex] to the vertices specified as
  /// the keys of the map [weightedEdges].
  void addEdges(T vertex, Map<T, W> weightedEdges) {
    if (_edges[vertex] == null) {
      // If vertex is new add it to the graph.
      _edges[vertex] = Map.of(weightedEdges);
    } else {
      _edges[vertex]!.addAll(weightedEdges);
    }

    /// Add any new connected vertices to the graph.
    for (final connectedVertex in weightedEdges.keys) {
      _edges[connectedVertex] ??= <T, W>{};
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
        _edges[vertex]!.containsKey(connectedVertex)) {
      return true;
    }
    return false;
  }

  /// Returns the vertices connected to [vertex].
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  @override
  Set<T> edges(T vertex) => _edges[vertex]?.keys.toSet() ?? <T>{};

  /// Returns a record containing the path connecting [start] and [target] with
  /// the largest summed edge-weight and the summed weight.
  ///
  /// Note: Returns an empty list and [zero] if no path could be found.
  ({List<T> vertices, W weight}) heaviestPath(T start, T target) {
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return (vertices: [], weight: zero);
    var maxWeight = zero;
    var bestPath = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(maxWeight) > 0) {
        // Reset maximum weight.
        maxWeight = currentWeight;
        bestPath = path;
      }
    }
    return (vertices: bestPath, weight: maxWeight);
  }

  /// Returns a record containing the path
  /// connecting [start] and [target] with
  /// the smallest summed edge-weight and the summed weight.
  /// * Returns an empty list  and [zero] if no path could be found.
  ({List<T> vertices, W weight}) lightestPath(T start, T target) {
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return (vertices: [], weight: zero);
    var minWeight = summation(weight, weight);
    var bestPath = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(minWeight) < 0) {
        // Reset minimum weight.
        minWeight = currentWeight;
        bestPath = path;
      }
    }
    return (vertices: bestPath, weight: minWeight);
  }

  /// Completely removes [vertex] from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    // Return early if vertex is unknown.
    if (!_edges.containsKey(vertex)) return;
    removeIncomingEdges(vertex);
    _edges.remove(vertex);
    updateCache();
  }

  /// Removes the edge pointing from [vertex] to [connectedVertex].
  /// Does not remove the vertices.
  void removeEdge(T vertex, T connectedVertex) {
    _edges[vertex]?.remove(connectedVertex);
    updateCache();
  }

  /// Removes edges pointing from [vertex] to [connectedVertices].
  ///
  /// Does not remove any vertices from the graph.
  void removeEdges(T vertex, Set<T> connectedVertices) {
    // Return early if vertex does not belong to the graph.
    if (!_edges.containsKey(vertex)) return;
    _edges[vertex]?.removeWhere(
      (connectedVertex, edgeWeight) =>
          connectedVertices.contains(connectedVertex),
    );
    updateCache();
  }

  /// Removes edges ending at [vertex] from the graph.
  ///
  /// Note: Does not remove any vertices from the graph.
  void removeIncomingEdges(T vertex) {
    // Return early if vertex is unknown.
    if (!_edges.containsKey(vertex)) return;
    for (final connectedVertices in _edges.values) {
      connectedVertices.remove(vertex);
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

  /// Sorts the neighbouring vertices of each vertex using [vertexComparator].
  /// * The optional parameter [vertexComparator] defaults to [comparator].
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

  /// Sorts the neighbouring vertices of each vertex using [weightComparator].
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  /// * Note: In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  void sortEdgesByWeight() {
    for (final vertex in vertices) {
      _edges[vertex]?.sortByValue(weightComparator);
    }
  }

  /// Returns a string representation of the weighted directed graph.
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

  @override
  void updateCache() {
    _weight.updateCache();
    super.updateCache();
  }

  /// Assigns [weight] to an existing edge connecting [vertex]
  /// to [connectedVertex].
  /// * Returns `true` on success.
  /// * Return `false` if there is no graph edge connecting [vertex] to
  /// [connectedVertex].
  /// * Note: To create an new graph edge connecting [vertex] to
  /// [connectedVertex] use the method [addEdge].
  bool updateEdgeWeight({
    required T vertex,
    required T connectedVertex,
    required W weight,
  }) {
    if (!edgeExists(vertex, connectedVertex)) {
      return false;
    } else {
      _edges[vertex]![connectedVertex] = weight;
      _weight.updateCache();
      return true;
    }
  }

  @override
  bool vertexExists(T vertex) => _edges.containsKey(vertex);

  /// Returns the weight obtained by traversing the iterable [walk] and
  /// summing all edge weights.
  /// * The vertices must be traversable in the specified order.
  /// * Vertices and edges may be repeated.
  /// * Throws an error if the [walk] cannot be traversed.
  /// * Returns zero if the iterable [walk] is empty.
  W weightAlong(Iterable<T> walk) {
    final edge = walk.take(2);
    if (edge.length < 2) {
      return zero;
    }
    final vertex = edge.first;
    final connectedVertex = edge.last;

    if (!_edges.containsKey(vertex)) {
      throw ErrorOfType<UnkownVertex>(
        message: 'Could not calculate weight of walk: $walk',
        invalidState: '$vertex is not a graph vertex.',
      );
    }
    if (!_edges[vertex]!.containsKey(connectedVertex)) {
      throw ErrorOfType<NotAnEdge>(
        message: 'Could not calculate the weight of walk: $walk.',
        invalidState: 'Vertex $vertex is not connected to $connectedVertex.}',
        expectedState: '$walk must be traversable using existing graph edges.',
      );
    }
    return summation(
      _edges[vertex]![connectedVertex]!,
      weightAlong(walk.skip(1)),
    );
  }

  /// Returns a map containing the vertices connected to [vertex] as keys
  /// and the weight associated with each edge as values.
  ///
  /// Returns an empty map if [vertex] is not connected to any other vertices
  /// or if [vertex] is not a graph vertex.
  Map<T, W> weightedEdges(T vertex) => Map.of(_edges[vertex] ?? <T, W>{});
}
