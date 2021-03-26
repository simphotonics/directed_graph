import 'package:exception_templates/exception_templates.dart';
import 'package:lazy_memo/lazy_memo.dart';

import '../exceptions/error_types.dart';
import '../extensions/sort.dart';
import 'directed_graph_base.dart';

/// Function used to sum edge weights.
typedef Summation<W> = W Function(W left, W right);

/// A directed graph with vertices of type `T` and a weight of type
/// `W` associated with each directed edges.
/// * `T` must be usable as a map key.
class WeightedDirectedGraph<T extends Object, W extends Comparable>
    extends DirectedGraphBase<T> {
  /// Constructs a weighted directed graph with vertices of type `T`
  /// and associates to each graph edge a weight of type `W`.
  /// * `edges`: The weighted edges of the graph. An empty map may
  /// be used to create an empty graph.
  /// * [zero]: The weight of an empty path. It represents the additive
  /// identity of the type `W`.
  /// * [summation]: The function used to sum edge weights.
  /// * Note: `W` must extend [Comparable].
  WeightedDirectedGraph(
    Map<T, Map<T, W>> edges, {
    required this.summation,
    required this.zero,
    Comparator<T>? comparator,
  }) : super(comparator) {
    edges.forEach((vertex, connectedVerticeWeights) {
      _edges[vertex] = Map.of(connectedVerticeWeights);
      for (final connectedVertex in connectedVerticeWeights.keys) {
        _edges[connectedVertex] ??= <T, W>{};
      }
    });
    _weight = Lazy<W>(() => _calculateWeight);
  }

  /// Constructs a shallow copy of `graph`.
  WeightedDirectedGraph.of(WeightedDirectedGraph<T, W> graph)
      : this(
          graph.data,
          summation: graph.summation,
          zero: graph.zero,
          comparator: graph.comparator,
        );

  /// Constructs the transitive closure of `graph`.
  factory WeightedDirectedGraph.transitiveClosure(
          WeightedDirectedGraph<T, W> graph) =>
      WeightedDirectedGraph(
        graph.transitiveWeightedEdges,
        comparator: graph.comparator,
        summation: graph.summation,
        zero: graph.zero,
      );

  /// The weight of an empty path.
  /// * Used as the initial value when summing the weight of a path.
  /// * Represents the additive identity of type `W`.
  /// * Has the property: `(w + zero) == w`, where `w` and `zero` are of type
  ///   `W`.
  /// * Examples: `int: 0`, `double: 0.0`, `String: ''`.
  final W zero;

  /// Graph edges.
  /// * Each graph vertex corresponds to a map key.
  final Map<T, Map<T, W>> _edges = {};

  /// Returns a list of all vertices.
  ///
  /// To retrieve a list of sorted vertices use the getter `sortedVertices`.
  @override
  Iterable<T> get vertices => _edges.keys;

  /// Returns the vertices connected to [vertex].
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  @override
  Iterable<T> edges(T vertex) =>
      _edges[vertex] == null ? <T>{} : _edges[vertex]!.keys;

  /// Lazy variable representing the graph weight.
  late final Lazy<W> _weight;

  /// Returns the sum of all graph edges.
  W get weight => _weight();

  /// Function used to sum edge weights.
  final Summation<W> summation;

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
  void updateCache() {
    _weight.updateCache();
    super.updateCache();
  }

  /// Adds weighted edges pointing from `vertex` to `weightedEdges.keys`.
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

  /// Adds a new weighted edge pointing from `vertex` to `connectedVertex`.
  ///
  /// If the edge `(vertex, connectedVertex`) exists,
  /// the edge `weight` is updated.
  void addEdge(T vertex, T connectedVertex, W weight) {
    if (_edges.containsKey(vertex)) {
      _edges[vertex]![connectedVertex] = weight;
    } else {
      _edges[vertex] = {connectedVertex: weight};
    }
    // Add any new vertices to the graph:
    _edges[connectedVertex] ??= <T, W>{};
  }

  /// Removes edges pointing from `vertex` to `connectedVertices`.
  ///
  /// Does not remove any vertices from the graph.
  void removeEdges(T vertex, Set<T> connectedVertices) {
    // Return early if vertex does not belong to the graph.
    if (!_edges.containsKey(vertex)) return;
    _edges[vertex]?.removeWhere(
      (connectedVertex, edgeWeight) => connectedVertices.contains(
        connectedVertex,
      ),
    );
    updateCache();
  }

  /// Removes edges ending at `vertex` from the graph.
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

  /// Completely removes `vertex` from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    // Return early if vertex is unknown.
    if (!_edges.containsKey(vertex)) return;
    removeIncomingEdges(vertex);
    _edges.remove(vertex);
    updateCache();
  }

  /// Removes all graph edges.
  void clear() {
    _edges.clear();
    updateCache();
  }

  /// Returns the weight obtained by traversing `walk` and
  /// summing all edge weights.
  /// * The vertices must be traversable in the specified order.
  /// * Vertices and edges may be repeated.
  /// * Throws an error if the `walk` cannot be traversed.
  /// * Returns zero if `walk` is empty.
  W weightAlong(Iterable<T> walk) {
    final edge = walk.take(2);
    if (edge.length < 2) {
      return zero;
    }
    final vertex = edge.first;
    final connectedVertex = edge.last;

    if (!_edges.containsKey(vertex)) {
      throw ErrorOfType<UnkownVertex>();
    }
    if (!_edges[vertex]!.containsKey(connectedVertex)) {
      throw ErrorOfType<NotAnEdge>(
        message: 'Could not calculate weight of path',
        invalidState: 'Vertex $vertex not connected to $connectedVertex.}',
      );
    }

    return summation(
        _edges[vertex]![connectedVertex]!, weightAlong(walk.skip(1)));
  }

  /// Returns the summed weight of all graph edges.
  W get _calculateWeight {
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
  }

  /// Sorts the neighbouring vertices of each vertex using [comparator].
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  /// * In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  /// * The optional parameter `vertexComparator` defaults to [comparator].
  void sortEdges([Comparator<T>? vertexComparator]) {
    if (comparator == null && vertexComparator == null) return;
    for (final vertex in vertices) {
      _edges[vertex]!.sortByKey(vertexComparator ?? comparator);
    }
  }

  /// Sorts the neighbouring vertices of each vertex using `weightComparator`.
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  /// * Note: In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  void sortEdgesByWeight([Comparator<W>? weightComparator]) {
    for (final vertex in vertices) {
      _edges[vertex]!.sortByValue(weightComparator);
    }
  }

  /// Returns the path connecting `start` and `target` with
  /// the smallest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> lightestPath(T start, T target) {
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var minWeight = summation(weight, weight);
    var result = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(minWeight) < 0) {
        // Reset minimum weight.
        minWeight = currentWeight;
        result = path;
      }
    }
    return result;
  }

  /// Returns the path connecting `start` and `target` with
  /// the largest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> heaviestPath(T start, T target) {
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var maxWeight = zero;
    var result = <T>[];
    for (final path in paths) {
      final currentWeight = weightAlong(path);
      if (currentWeight.compareTo(maxWeight) > 0) {
        // Reset maximum weight.
        maxWeight = currentWeight;
        result = path;
      }
    }
    return result;
  }

  /// Returns the weighted edges representing the
  /// transitive closure of `this`.
  Map<T, Map<T, W>> get transitiveWeightedEdges {
    final tcEdges = <T, Map<T, W>>{};
    final maxWeight = summation(weight, weight);
    for (final vertex in sortedVertices) {
      // Weighted edges connected to vertex:
      final weightedEdges = <T, W>{};
      final mappedTree = crawler.mappedTree(vertex);
      for (final connectedVertex in mappedTree.keys) {
        // Calculate min. weight.
        var minWeight = maxWeight;
        for (final path in mappedTree[connectedVertex]!) {
          final currentWeight = weightAlong([vertex, ...path]);
          if (currentWeight.compareTo(minWeight) < 0) {
            minWeight = currentWeight;
          }
        }

        weightedEdges[connectedVertex] = minWeight;
      }
      tcEdges[vertex] = weightedEdges;
    }
    return tcEdges;
  }

  @override
  Iterator<T> get iterator => vertices.iterator;

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
          _edges[vertex]!.keys.map<String>((key) => '$q$key$q: '
              '${_edges[vertex]![key]}'),
          ', ');

      b.write('},');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }
}
