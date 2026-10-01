import 'package:directed_graph/src/enum/edge_selector.dart';
import 'package:exception_templates/exception_templates.dart';
import 'package:lazy_memo/lazy_memo.dart';

import '../exceptions/error_types.dart';
import '../extensions/sort.dart';
import 'directed_graph_base.dart';

/// A directed graph storing vertices of type [T] and edge weights of type
/// [W].
/// * There can be several edges between two vertices.
/// * [T] must be usable as a map key.
class WeightedDirectedMultiGraph<T extends Object, W extends Comparable<Object>>
    extends DirectedGraphBase<T> {
  /// The weight of an empty path.
  /// * Used as the initial value when summing the weight of a path.
  /// * Represents the additive identity of the type [W].
  /// * Has the property: `(w + zero) == w`, where `w` is any object of type
  ///   [W].
  /// * Examples: [int]: 0, [double]: 0.0, [String]: ''.
  final W zero;

  /// Stores the graph edges.
  /// Each graph vertex corresponds to a map key.
  /// There can be multiple edges between two vertices.
  final Map<T, Map<T, List<W>>> _edges = {};

  /// Function used to sum edge weights.
  final Summation<W> summation;

  /// Constructs a weighted directed graph with vertices of type [T]
  /// edge weight of type [W].
  /// * [edges]: The weighted edges of the graph. An empty map may
  /// be used to create an empty graph.
  /// * [zero]: The weight of an empty path. It represents the additive
  /// identity of the type [W].
  /// * [summation]: The function used to sum edge weights.
  /// * Note: [W] must extend [Comparable].
  new(
    Map<T, Map<T, List<W>>> edges, {
    required this.summation,
    required this.zero,
    Comparator<T>? comparator,
    Comparator<W>? weightComparator,
  }) : _weightComparator = weightComparator ?? defaultWeightComparator,
       super(comparator) {
    edges.forEach((vertex, edgeWeights) {
      _edges[vertex] = {
        for (final connectedVertex in edgeWeights.keys)
          connectedVertex: List.of(edgeWeights[connectedVertex]!)
            ..sort(weightComparator),
      };

      for (final connectedVertex in edgeWeights.keys) {
        _edges[connectedVertex] ??= <T, List<W>>{};
      }
    });
  }

  /// Constructs a shallow copy of [graph].
  new of(WeightedDirectedMultiGraph<T, W> graph)
    : this(
        graph.data,
        summation: graph.summation,
        zero: graph.zero,
        comparator: graph.comparator,
      );

  /// Returns a copy of the weighted edges
  /// as an object of type `Map<T, Map<T, List<W>>>`.
  Map<T, Map<T, List<W>>> get data {
    final out = <T, Map<T, List<W>>>{};
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
  Comparator<W> get weightComparator => _weightComparator;

  /// The comparator used to sort edge weights.
  /// This field holds either:
  /// * the comparator provided as constructor parameter,
  /// * the comparator set by the user,
  /// * the default comparator.
  Comparator<W> _weightComparator;

  /// Sets the [weightComparator] and sorts the edge weights.
  set weightComparator(Comparator<W> weightComparator) {
    _weightComparator = weightComparator;
    _sortEdgeWeigths();
  }

  /// Sorts the edge weights using [comparator].
  void _sortEdgeWeigths() {
    // Sort edge weights
    for (final vertex in vertices) {
      for (final connectedVertex in _edges[vertex]!.keys) {
        _edges[vertex]![connectedVertex]!.sort(_weightComparator);
      }
    }
  }

  /// Lazy variable representing the total graph weight.
  late final _weight = Lazy<W>(() {
    var sum = zero;
    for (final vertex in vertices) {
      var partialSum = zero;
      // Adding weight of edges connected to vertex.
      for (final weights in _edges[vertex]!.values) {
        partialSum = summation(
          partialSum,
          weights.fold<W>(zero, (weight, sum) => summation(weight, sum)),
        );
      }
      sum = summation(sum, partialSum);
    }
    return sum;
  });

  /// Returns the sum of all graph edges.
  W get weight => _weight();

  /// Adds a new weighted edge pointing from [vertex] to [connectedVertex].
  void addEdge(T vertex, T connectedVertex, W weight) {
    if (_edges.containsKey(vertex)) {
      if (_edges[vertex]!.containsKey(connectedVertex)) {
        _edges[vertex]![connectedVertex]!.add(weight);
        _edges[vertex]![connectedVertex]!.sort(weightComparator);
      } else {
        _edges[vertex]![connectedVertex] = [weight];
      }
    } else {
      _edges[vertex] = {
        connectedVertex: [weight],
      };
    }
    // Add any new vertices to the graph:
    _edges[connectedVertex] ??= <T, List<W>>{};
    updateCache();
  }

  /// Adds weighted edges pointing from [vertex] to the vertices specified as
  /// the keys of the map [weightedEdges].
  void addEdges(T vertex, Map<T, List<W>> weightedEdges) {
    if (_edges[vertex] == null) {
      // If vertex is new add it to the graph.
      _edges[vertex] = {
        for (final key in weightedEdges.keys)
          key: weightedEdges[key]!..sort(weightComparator),
      };
    } else {
      // If vertex exists, add new edges. Note: Don't overwrite existing edges.
      for (final connectedVertex in weightedEdges.keys) {
        if (_edges[vertex]![connectedVertex] == null) {
          _edges[vertex]![connectedVertex] = weightedEdges[connectedVertex]!
            ..sort(weightComparator);
        } else {
          _edges[vertex]![connectedVertex] =
              (_edges[vertex]![connectedVertex]!
                  ..addAll(weightedEdges[connectedVertex]!))
                ..sort(weightComparator);
        }
      }
    }

    /// Add any newly connected vertices to the graph.
    for (final connectedVertex in weightedEdges.keys) {
      _edges[connectedVertex] ??= <T, List<W>>{};
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
  bool edgeExists(T vertex, T connectedVertex) =>
      (_edges.containsKey(vertex) &&
      _edges[vertex]!.containsKey(connectedVertex));

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
      final currentWeight = weightAlong(
        path,
        selector: EdgeSelector.highestWeight,
      );
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
    var bestPath = <T>[];
    if (paths.isEmpty) return (vertices: bestPath, weight: zero);
    var minWeight = summation(weight, weight);
    for (final path in paths) {
      final currentWeight = weightAlong(
        path,
        selector: EdgeSelector.lowestWeight,
      );
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

  /// Removes the edge with [weight] pointing from [vertex] to [connectedVertex].
  /// Does not remove the vertices.
  void removeEdge(T vertex, T connectedVertex, W weight) {
    if (_edges[vertex]?[connectedVertex]?.remove(weight) ?? false) {
      if (_edges[vertex]![connectedVertex]!.isEmpty) {
        _edges[vertex]!.remove(connectedVertex);
      }
      updateCache();
    }
  }

  /// Removes edges pointing from [vertex] and specified by
  /// [edgeWeights].
  ///
  /// * Does not remove any vertices from the graph.
  /// * Calls [updateCache] if any edges were removed.
  void removeEdges(T vertex, Map<T, List<W>> edgeWeights) {
    edgeWeights.forEach((connectedVertex, weights) {
      for (final weight in weights) {
        removeEdge(vertex, connectedVertex, weight);
      }
    });
  }

  /// Removes edges ending at [vertex] from the graph.
  ///
  /// Note: Does not remove any vertices from the graph.
  void removeIncomingEdges(T vertex) {
    // Return early if vertex is unknown.
    if (!_edges.containsKey(vertex)) return;
    for (final edgeWeights in _edges.values) {
      edgeWeights.remove(vertex);
    }
    updateCache();
  }

  /// Sorts the graph vertices using [comparator] and then calls
  /// [sortEdges].
  /// * Without sorting, the graph vertices are listed in insertion order.
  /// * Note: In general, adding further vertices and graph edges invalidates
  /// the sorting.
  void sort() {
    if (hasComparator) {
      _edges.sortByKey(comparator);
      sortEdges();
    }
  }

  /// Sorts the neighbouring vertices of each vertex using [comparator].
  /// * By default the neighbouring vertices of a vertex are listed in
  ///   insertion order.
  /// * In general, adding further graph edges invalidates
  ///   the sorting of neighbouring vertices.
  void sortEdges() {
    if (hasComparator) {
      for (final vertex in vertices) {
        _edges[vertex]!.sortByKey(comparator);
      }
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

  @override
  bool vertexExists(T vertex) => _edges.containsKey(vertex);

  /// Returns the weight obtained by traversing the iterable [walk] and
  /// summing all edge weights.
  /// * The vertices must be traversable in the specified order.
  /// * Vertices and edges may be repeated.
  /// * Throws an error if the [walk] cannot be traversed.
  /// * Returns zero if the iterable [walk] is empty.
  /// * By default, the edge with the lowest associated weight is selected.
  ///   To select the heaviest edge set [selector] to
  ///   [EdgeSelector.highestWeight].
  W weightAlong(
    Iterable<T> walk, {
    EdgeSelector selector = EdgeSelector.lowestWeight,
  }) {
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
    return summation(switch (selector) {
      EdgeSelector.lowestWeight => _edges[vertex]![connectedVertex]!.first,
      EdgeSelector.highestWeight => _edges[vertex]![connectedVertex]!.last,
    }, weightAlong(walk.skip(1)));
  }

  /// Returns a map containing the vertices connected to [vertex] as keys
  /// and a list of weights associated with each edge as values.
  ///
  /// Returns an empty map if [vertex] is not connected to any other vertices
  /// or if [vertex] is not a graph vertex.
  Map<T, List<W>> weightedEdges(T vertex) =>
      Map.of(_edges[vertex] ?? <T, List<W>>{});
}
