import 'dart:collection';

import 'package:directed_graph/src/exceptions/error_types.dart';
import 'package:exception_templates/exception_templates.dart';

import '../../directed_graph.dart';

/// Function used to sum edge weights.
typedef Summation<W> = W Function(W left, W right);

/// Target of optimization.
enum Extremum { min, max }

int defaultComparator<W extends Comparable>(W left, W right) =>
    left.compareTo(right);

/// Branch of linked vertices of type `T` with an associated weight of type `W`
class WeightedBranch<T, W extends Comparable> {
  WeightedBranch(
    this.vertices,
    this.weight,
    //this.summation,
  );
  WeightedBranch.from(WeightedBranch<T, W> weightedBranch)
      : vertices = [...weightedBranch.vertices],
        weight = weightedBranch.weight;
  //summation = weightedBranch.summation;

  /// Vertices in branch.
  final List<T> vertices;

  /// Weight associated with this branch
  W weight;

  /// Function used to sum vertex weights.
  //final Summation<W> summation;

  /// Adds `vertex` to branch and recalculates weight.
  void add(T vertex, W weight) {
    vertices.add(vertex);
    this.weight = weight;
    //this.weight = summation(this.weight, weight);
  }

  /// Adds `vertices` to branch and recalculates branch weight.
  void addAll(Iterable<T> vertices, W weight) {
    this.weight = weight;
    this.vertices.addAll(vertices);
    //this.weight = summation(this.weight, weight);
  }

  /// Returns the branch length.
  int get length => vertices.length;

  /// Returns true if vertices is empty.
  bool get isEmpty => vertices.isEmpty;

  @override
  String toString() {
    return '$vertices=>$weight';
  }

  bool operator >(WeightedBranch<T, W> other) {
    return weight.compareTo(other.weight) > 0;
  }

  bool operator <(WeightedBranch<T, W> other) {
    return weight.compareTo(other.weight) < 0;
  }
}

/// A directed graph with vertices of type `T` and weights of type
/// `W` attached to each directed edges.
///
/// * `T` should be usable as a map key.
class WeightedDirectedGraph<T, W extends Comparable> extends DirectedGraph<T> {
  /// Constructs a weighted directed graph with vertices of type `T`
  /// and associates to each graph edge a weight of type `W`.
  ///
  /// * [zero]: The weight of an empty path. It represents the additive
  /// identity of the type `W`.
  /// * [summation]: The function used to sum edge weights.
  /// * Note: `W` must extend [Comparable].
  WeightedDirectedGraph(
    Map<T, Map<T, W>> weightedEdges, {
    required this.summation,
    required this.zero,
    Comparator<T>? comparator,
  }) : super.fromWeightedEdges(weightedEdges, comparator: comparator) {
    weightedEdges.forEach((vertex, connectedVerticeWeights) {
      _weightedEdges[vertex] = Map.of(connectedVerticeWeights);
      for (final connectedVertex in connectedVerticeWeights.keys) {
        _weightedEdges[connectedVertex] ??= <T, W>{};
      }
    });
  }

  /// Constructs the transitive closure of [graph].
  factory WeightedDirectedGraph.transitiveClosure(
      WeightedDirectedGraph<T, W> graph) {
    final tcEdges = <T, Map<T, W>>{};

    void addReachableVertices(T root, T current) {
      for (final vertex in graph.edges(current)) {
        if (tcEdges[root]!.containsKey(vertex)) continue;
        tcEdges[root]![vertex] =
            graph.pathWeight(graph.lightestPath(root, vertex));
        addReachableVertices(root, vertex);
      }
    }

    for (final root in graph) {
      tcEdges[root] = <T, W>{};
      addReachableVertices(root, root);
    }

    return WeightedDirectedGraph(tcEdges,
        comparator: graph.comparator,
        zero: graph.zero,
        summation: graph.summation);
  }

  /// The weight of an empty path.
  /// * Used as the initial value when summing the weight of a path.
  /// * Represents the additive identity of type `W`.
  /// * Has the property: `(w + zero) == w`, where `w` and `zero` are of type
  ///   `W`.
  /// * Examples: `int: 0`, `double: 0.0`, `String: ''`.
  final W zero;

  /// A large weight used by path finding algorithms.
  /// If not value is given it will be initialized as twice the weight of graph.
  //late W infinity;

  /// Lazy backup of the graph weight.
  late W _weightBackup;

  /// Marks lazy getters as up to date.
  var _isUpToDate = false;

  /// Stores vertices of type `T` and the edge weights of type `W`.
  final Map<T, Map<T, W>> _weightedEdges = {};

  /// Function used to sum edge weights.
  final Summation<W> summation;

  /// Returns a copy of the weighted edges
  /// as an object of type `Map<T, Map<T, W>>`.
  Map<T, Map<T, W>> get weightedGraphData {
    final out = <T, Map<T, W>>{};
    for (final vertex in vertices) {
      out[vertex] = _weightedEdges[vertex]!;
    }
    return out;
  }

  /// Adds weighted edges pointing from [vertex] to `weightedEdges.keys`.
  void addWeightedEdges(T vertex, Map<T, W> weightedEdges) {
    if (_weightedEdges[vertex] == null) {
      _weightedEdges[vertex] = Map.of(weightedEdges);
    } else {
      _weightedEdges[vertex]!.addAll(weightedEdges);
    }
    for (final connectedVertex in weightedEdges.keys) {
      _weightedEdges[connectedVertex] ??= <T, W>{};
    }
    super.addEdges(vertex, weightedEdges.keys.toSet());
  }

  @override
  void addEdges(T vertex, Set<T> edges) {
    final weightedEdges = <T, W>{};
    edges.forEach((edge) => weightedEdges[edge] = zero);
    addWeightedEdges(vertex, weightedEdges);
    super.addEdges(vertex, edges);
  }

  @override
  void removeEdges(T vertex, Set<T> connectedVertices) {
    _weightedEdges[vertex]
        ?.removeWhere((key, value) => connectedVertices.contains(key));
    super.removeEdges(vertex, connectedVertices);
  }

  @override
  void removeIncomingEdges(T vertex) {
    if (_weightedEdges[vertex] == null) return;
    for (final connectedVertices in _weightedEdges.values) {
      connectedVertices.remove(vertex);
    }
    super.removeIncomingEdges(vertex);
  }

  @override
  void remove(T vertex) {
    if (_weightedEdges[vertex] == null) return;
    removeIncomingEdges(vertex);
    _weightedEdges.remove(vertex);
    super.remove(vertex);
  }

  /// Returns the summed weight associated with `path`.
  ///
  /// * Throws an error if the path cannot be traversed.
  /// * Returns zero if the path is empty.
  W pathWeight(List<T> path) {
    if (path.length < 2) {
      return zero;
    }
    final vertex = path[0];
    final connectedVertex = path[1];
    if (!_weightedEdges.containsKey(vertex)) {
      throw ErrorOfType<UnkownVertex>();
    }
    if (!_weightedEdges[vertex]!.containsKey(connectedVertex)) {
      throw ErrorOfType<NotAnEdge>(
        message: 'Could not calculate weight of path',
        invalidState: 'Vertex $vertex not connected to $connectedVertex.}',
      );
    }
    return (path.length == 2)
        ? _weightedEdges[vertex]![connectedVertex]!
        : summation(_weightedEdges[vertex]![connectedVertex]!,
            pathWeight(List<T>.of(path.skip(1))));
  }

  /// Returns the summed weight of all graph edges.
  W get weight {
    if (_isUpToDate) return _weightBackup;
    var sum = zero;
    for (final vertex in _weightedEdges.keys) {
      var partialSum = zero;
      // Adding weight of edges connected to vertex.
      for (final weight in _weightedEdges[vertex]!.values) {
        partialSum = summation(partialSum, weight);
      }
      sum = summation(sum, partialSum);
    }
    _weightBackup = sum;
    _isUpToDate = true;
    return sum;
  }

  /// Returns the path connecting [start] and [target] with
  /// the smallest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> lightestPath(T start, T target) {
    final crawler = GraphCrawler(super.edges);
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var maxWeight = summation(weight, weight);
    var out = <T>[];
    for (final current in paths) {
      final currentWeight = pathWeight(current);
      if (currentWeight.compareTo(maxWeight) < 0) {
        // Reset maximum weight.
        maxWeight = currentWeight;
        out = current;
      }
    }
    return out;
  }

  /// Returns the path connecting [start] and [target] with
  /// the largest summed edge-weight.
  /// * Returns an empty list if no path could be found.
  List<T> heaviestPath(T start, T target) {
    final crawler = GraphCrawler(super.edges);
    final paths = crawler.paths(start, target);
    if (paths.isEmpty) return [];
    var minWeight = zero;
    var out = <T>[];
    for (final current in paths) {
      final currentWeight = pathWeight(current);
      if (currentWeight.compareTo(minWeight) > 0) {
        // Reset maximum weight.
        minWeight = currentWeight;
        out = current;
      }
    }
    return out;
  }

  List<T> optimalPath(T start, T target, {Extremum extremum = Extremum.min}) {
    final weightExtremum =
        (extremum == Extremum.min) ? summation(weight, weight) : zero;

    // Stores results.
    var resultBranch = WeightedBranch<T, W>(
      [],
      weightExtremum,
      //summation,
    );

    final leftIsBetterWeight = (extremum == Extremum.min)
        ? (W left, W right) {
            return left.compareTo(right) < 0;
          }
        : (W left, W right) {
            return left.compareTo(right) > 0;
          };

    final leftIsBetterBranch = (extremum == Extremum.min)
        ? (WeightedBranch<T, W> left, WeightedBranch<T, W> right) {
            return left < right;
          }
        : (WeightedBranch<T, W> left, WeightedBranch<T, W> right) {
            return left > right;
          };

    /// Visited vertices.
    final visited = <T>{};

    /// Stores previously walked optimal paths.
    final branches = <T, WeightedBranch<T, W>>{};

    /// Holds a list of vertices to be visited.
    final queue = ListQueue<T>()..add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      // print('Current: $current:');

      for (final connected in edges(current)) {
        // if (branches[connected] == null) {
        //   if (branches[current] == null) {
        //     branches[connected] = WeightedBranch<T, W>(
        //       [
        //         current,
        //         connected,
        //       ],
        //       _weightedEdges[current]![connected]!,
        //       //summation,
        //     );
        //   } else {
        //     branches[connected] = WeightedBranch.from(branches[current]!)
        //       ..add(
        //         connected,
        //         summation(
        //           branches[current]!.weight,
        //           _weightedEdges[current]![connected]!,
        //         ),
        //       );
        //   }
        // } else {
        //   final newWeight = summation(
        //     branches[current]!.weight,
        //     _weightedEdges[current]![connected]!,
        //   );
        //   final previousWeight = branches[connected]!.weight;

        //   // Update branch if a better alternative is found.
        //   if (leftIsBetterWeight(newWeight, previousWeight)) {
        //     branches[connected] = WeightedBranch.from(branches[current]!)
        //       ..add(connected, _weightedEdges[current]![connected]!);
        //   }
        // }

        if (branches[current] == null && branches[connected] == null) {
          branches[connected] = WeightedBranch<T, W>(
            [
              current,
              connected,
            ],
            _weightedEdges[current]![connected]!,
          );
        }
        if (branches[current] != null) {
          final newWeight = summation(
            branches[current]!.weight,
            _weightedEdges[current]![connected]!,
          );

          if (branches[connected] == null) {
            branches[connected] = WeightedBranch.from(branches[current]!)
              ..add(connected, newWeight);
          } else {
            final previousWeight = branches[connected]!.weight;

            // Update branch if a better alternative is found.
            if (leftIsBetterWeight(newWeight, previousWeight)) {
              branches[connected] = WeightedBranch.from(branches[current]!)
                ..add(connected, newWeight);
            }
          }
        }

        // if (branches[current] == null && branches[connected] != null) {
        //   print('doing nothing! branches[$current] == null ');
        //   print('branches[$connected] = ${branches[connected]}');
        // }

        // ===================================

        if (leftIsBetterBranch(branches[connected]!, resultBranch)) {
          // Update result branch.
          if (connected == target) resultBranch = branches[connected]!;

          // Add connected vertex to queue.
          if (!visited.contains(connected)) {
            queue.add(connected);
            visited.add(connected);
          }
        }

        // stdin.readLineSync();
        // print(resultBranch);
        // print(branches);
        // print(queue);
        // print('-------');
      }
    }
    return resultBranch.vertices;
  }

  /// Returns a string representation of the weighted directed graph.
  @override
  String toString() {
    var b = StringBuffer();
    final q = (T == String) ? '\'' : '';

    b.writeln('{');
    for (final vertex in vertices) {
      b.write(' $q$vertex$q: ');
      b.write('{');
      b.writeAll(
          _weightedEdges[vertex]!.keys.map<String>((key) => '$q$key$q: '
              '${_weightedEdges[vertex]![key]}'),
          ', ');

      b.write('},');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }
}
