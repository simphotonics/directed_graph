/// Dart implementation of a directed graph.
/// Provides methods to
/// * add/remove edges,
/// * check if the graph is acyclic,
/// * retrieve cycles,
/// * retrieve a list of vertices in topological order.
library directed_graph;

import 'dart:collection' show HashSet, Queue, UnmodifiableListView;
import 'package:graphs/graphs.dart' as graphs;
import 'package:lazy_evaluation/lazy_evaluation.dart';
import 'package:meta/meta.dart';

/// Function returning a list of edge vertices.
/// If a vertex has no neighbours it should return
/// an empty list.
///
/// Note: The function should never return null.
typedef Edges<T> = List<Vertex<T>> Function(Vertex<T> vertex);

/// Vertex mark used by sorting algorithms.
enum _Mark { PERMANENT, TEMPORARY }

/// Generic object representing a vertex in a graph.
/// Holds data of type [T].
class Vertex<T> {
  /// Vertex id.
  final int _id;

  /// Vertex data of type [T].
  final T data;

  /// Vertex counter.
  static int _counter = 0;

  /// Creates a vertex holding generic data of type [T].
  Vertex(this.data) : _id = ++_counter;

  Vertex.fromConstantVertex(ConstantVertex vertex)
      : _id = ++_counter,
        data = vertex.data;

  /// Returns the integer [id] of the vertex.
  int get id => _id;

  @override
  bool operator ==(Object other) => other is Vertex<T> && other.id == _id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => '$data';

  /// Private field used by DFS algorithms.
  _Mark _mark;

  /// Private field used by [GraphCrawler].
  /// Keeps a tab of visited neighbouring vertices.
  final _visited = HashSet<Vertex<T>>();
}

/// Object representing a constant vertex.
class ConstantVertex<T> {
  /// Vertex data of type [T].
  final T data;

  /// Creates a vertex holding generic data of type [T].
  const ConstantVertex(this.data);

  @override
  bool operator ==(Object other) =>
      other is ConstantVertex<T> && other.hashCode == hashCode;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => '$data';
}

/// Generic directed graph.
/// Data of type [T] is stored in vertices of type [Vertex<T>].
/// The graph consists of a mapping [_edges] of each
/// [Vertex<T>] to a list of connected vertices [List<Vertex<T>>].
class DirectedGraph<T> extends Iterable {
  Map<Vertex<T>, List<Vertex<T>>> _edges;
  MutableLazy<UnmodifiableListView<Vertex<T>>> _vertices;
  Map<Vertex<T>, int> _inDegreeMap;
  Comparator<Vertex<T>> _comparator;

  /// Constructs a directed graph.
  /// [edges] is of type [Map<Vertex<T>, List<Vertex<T>>>],
  /// mapping each vertex to a list of connected vertices.
  DirectedGraph(
    Map<Vertex<T>, List<Vertex<T>>> edges, {
    Comparator<Vertex<T>> comparator,
  })  : _edges = edges ?? {},
        _comparator = comparator {
    _inDegreeMap = _createInDegreeMap();
    _vertices = MutableLazy<UnmodifiableListView<Vertex<T>>>(_sortedVertices);
  }

  /// Constructs a directed graph from another directed graph.
  DirectedGraph.from(DirectedGraph<T> directedGraph)
      : this(directedGraph._edges, comparator: directedGraph.comparator);

  /// Returns an unmodifiable list-view of sorted vertices.
  /// Vertices are sorted if a comparator was specified.
  UnmodifiableListView<Vertex<T>> _sortedVertices() {
    var vertices = _inDegreeMap.keys.toList();
    if (_comparator != null) vertices.sort(_comparator);
    return UnmodifiableListView(vertices);
  }

  Comparator<Vertex<T>> get comparator => _comparator;

  set comparator(Comparator<Vertex<T>> comparator) {
    _comparator = comparator;
    _vertices.notifyChange();
  }

  /// Mapping each graph vertex to a list of connected vertice.
  Map<Vertex<T>, List<Vertex<T>>> get edgeMap => _edges;

  /// Returns a list of the connected vertices of [vertex].
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  List<Vertex<T>> edges(Vertex<T> vertex) => _edges[vertex] ?? [];

  /// Unmodifiable ListView of all vertices in the graph.
  /// The vertices will be sorted if a vertex comparator was
  /// specified during instantiation of the graph or
  /// by invoking the `comparator` setter.
  UnmodifiableListView<Vertex<T>> get vertices => _vertices.value;

  /// Returns a (modifiable) copy of the inDegreeMap.
  Map<Vertex<T>, int> get inDegreeMap => Map<Vertex<T>, int>.from(_inDegreeMap);

  /// Call this method whenever vertices or edges are added to the graph.
  void _updateLazyFields() {
    _vertices.notifyChange();
  }

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
  /// If connectedVertices is not specified all outgoing
  /// edges are removed from the graph.
  void removeEdges(Vertex<T> vertex, [List<Vertex<T>> connectedVertices]) {
    // Handle default case: Remove all outgoing edges if
    // connectedVertices is not specified.
    if (connectedVertices == null) {
      // Update inDegreeMap.
      for (final connectedVertex in _edges[vertex] ?? []) {
        _inDegreeMap[connectedVertex] -= 1;
      }
      _edges.remove(vertex);
    } else {
      if (_edges[vertex] == null) return;
      for (final connectedVertex in connectedVertices) {
        // Check if connectedVertex is indeed connected to vertex.
        if (_edges[vertex].remove(connectedVertex)) {
          _inDegreeMap[connectedVertex] -= 1;
        }
      }
      // Remove entry if vertex has no outgoing edges.
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

  /// Completely remove [vertex] from the graph, including outgoing
  /// and incoming edges.
  void remove(Vertex<T> vertex) {
    removeIncomingEdges(vertex);
    _inDegreeMap.remove(vertex);
    removeEdges(vertex);
  }

  /// Returns a valid reverse topological order ordering of the
  /// strongly connected components.
  /// Acyclic graphs will yield components containing one vertex only.
  List<List<Vertex<T>>> get stronglyConnectedComponents {
    return graphs.stronglyConnectedComponents<Vertex<T>>(_edges.keys, edges);
  }

  /// Returns the shortest path between [start] and [target].
  /// Returns [null] if [start] is not connected to [target].
  List<Vertex<T>> shortestPath(Vertex<T> start, Vertex<T> target) {
    return graphs.shortestPath<Vertex<T>>(start, target, edges);
  }

  /// Returns a [Map] of the shortest paths from [start] to each node
  /// in the directed graph defined by [edges].
  Map<Vertex<T>, List<Vertex<T>>> shortestPaths(Vertex<T> start) {
    return graphs.shortestPaths<Vertex<T>>(start, edges);
  }

  /// Returns true if the graph is a directed acyclic graph.
  bool get isAcyclic {
    return (topologicalOrdering == null) ? false : true;
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
  List<List<Vertex<T>>> get localSources {
    final result = <List<Vertex<T>>>[];

    // Get modifiable in-degree map.
    final _inDegreeMap = inDegreeMap;

    // Get modifiable list of the graph vertices
    final _vertices = List.from(vertices);

    var hasSources = false;
    var count = 0;

    // Note: In an acyclic directed graph at least one
    // vertex has outDegree zero.
    do {
      // Storing local sources.
      final sources = <Vertex<T>>[];

      // Storing remaining vertices.
      final remainingVertices = <Vertex<T>>[];

      // Find local sources.
      for (final vertex in _vertices) {
        if (_inDegreeMap[vertex] == 0) {
          sources.add(vertex);
          ++count;
        } else {
          remainingVertices.add(vertex);
        }
      }

      // Add sources to result:
      if (sources.isNotEmpty) result.add(sources);

      // Simulate the removal of detected local sources.
      for (final source in sources) {
        for (final connectedVertex in _edges[source] ?? []) {
          _inDegreeMap[connectedVertex] -= 1;
        }
      }
      // Check if local source were found.
      hasSources = sources.isNotEmpty;

      // Replacing vertices with remaining vertices.
      _vertices.clear();
      _vertices.addAll(remainingVertices);
    } while (hasSources);

    return (count == inDegreeMap.keys.length) ? result : null;
  }

  /// Returns [List<Vertex<T>>], a list of all vertices in topological order.
  /// For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// If a vertex comparator is specified, the sorting will be applied
  /// in addition to the topological order. If
  ///
  /// Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns [null].
  /// Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// Based on Kahn's algorithm.
  List<Vertex<T>> get sortedTopologicalOrdering {
    if (_comparator == null) return topologicalOrdering;

    final result = <Vertex<T>>[];

    // Get modifiable in-degree map.
    final inDegreeMap = this.inDegreeMap;

    // Add all sources (vertices with inDegree == 0) to queue.
    // Using a list instead of a queue to enable sorting of [sources].
    //
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    final sources = <Vertex<T>>[];
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
      for (final vertex in _edges[current] ?? []) {
        inDegreeMap[vertex] -= 1;

        // Add new local source vertices of the remaining graph to the queue.
        if (inDegreeMap[vertex] == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }
    return (count != _inDegreeMap.length) ? null : result;
  }

  /// Returns [List<Vertex<T>>], a list of all vertices in topological order.
  /// For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns [null].
  /// Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// Based on a depth-first search algorithm (Cormen 2001, Tarjan 1976).
  List<Vertex<T>> get topologicalOrdering {
    final queue = Queue<Vertex<T>>();

    // Marks [this] graph as cyclic.
    var isCyclic = false;

    // Recursive function
    void visit(Vertex<T> vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // Vertex has permanent mark.
      // => This vertex and its neighbouring vertices
      // have already been visited.
      if (vertex._mark == _Mark.PERMANENT) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (vertex._mark == _Mark.TEMPORARY) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      vertex._mark = _Mark.TEMPORARY;
      for (final connectedVertex in _edges[vertex] ?? <Vertex<T>>[]) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      // We tried all options.
      vertex._mark = _Mark.PERMANENT;
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
    for (final current in vertices.reversed) {
      if (isCyclic) break;
      visit(current);
    }

    // Clearing vertex marks.
    // Important! Otherwise method won't be idempotent.
    for (final vertex in vertices) {
      vertex._mark = null;
    }
    //_VertexMarker.vertexMarks.clear();

    // Return null if graph is not a DAG.
    return (isCyclic) ? null : queue.toList();
  }

  /// Returns the first cycle detected or an empty list
  /// if the graph is acyclic.
  ///
  /// Note: A cycle is a path that starts and ends with
  /// the same vertex.
  List<Vertex<T>> get cycle {
    /// Start vertex of the cycle.
    Vertex<T> start;

    // Marks [this] graph as acyclic.
    var isCyclic = false;

    // Recursive function
    void visit(Vertex<T> vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // Vertex has permanent mark.
      // => This vertex and its neighbouring vertices have already been visited.
      if (vertex._mark == _Mark.PERMANENT) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (vertex._mark == _Mark.TEMPORARY) {
        start = vertex;
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      vertex._mark = _Mark.TEMPORARY;
      for (final connectedVertex in _edges[vertex] ?? <Vertex<T>>[]) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      vertex._mark = _Mark.PERMANENT;
    }

    // Main loop
    for (final vertex in vertices) {
      if (isCyclic) break;
      visit(vertex);
    }

    // Reset vertex mark.
    // Important! Otherwise method is not idempotent.
    for (final vertex in vertices) {
      vertex._mark = null;
    }

    // Find cycle path.
    if (isCyclic) {
      final GraphCrawler crawler = GraphCrawler<T>(edges: edges);
      return crawler.paths(start, start)?.first ?? [];
    } else {
      return [];
    }
  }

  /// Returns the first cycle detected or an empty list
  /// if the graph is acyclic.
  /// In general, the getter method [cycle] is faster, but
  /// [findCycle()] is efficient if the graph is sparcely
  /// connected.
  ///
  /// Note: A cycle is a path that starts and ends with
  /// the same vertex.
  List<Vertex<T>> findCycle() {
    final GraphCrawler crawler = GraphCrawler<T>(edges: edges);
    List<List<Vertex<T>>> cycle;

    // Main loop
    for (final vertex in vertices) {
      if (_inDegreeMap[vertex] == 0) continue;
      if (outDegree(vertex) == 0) continue;
      cycle = crawler.paths(vertex, vertex);
      if (cycle.isNotEmpty) return cycle.first;
    }
    return [];
  }

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<Vertex<T>, int> _createInDegreeMap() {
    var map = <Vertex<T>, int>{};
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
    var inDegree = 0;
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
  Map<Vertex<T>, int> get outDegreeMap {
    var map = <Vertex<T>, int>{};
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

  @override
  Iterator<Vertex<T>> get iterator => _vertices.value.iterator;
}

// /// Extension on Vertex<T> providing
// /// the field [mark].
// extension _VertexMarker<T> on Vertex<T> {
//   static final vertexMarks = <int, _Mark>{};

//   _Mark get mark => vertexMarks[id];

//   set mark(_Mark mark) {
//     vertexMarks[id] = mark;
//   }
// }

/// Crawls a graph defined by [edges] and records
/// every path from `start` to `target`.
/// The result is available via the getter [paths]
/// which returns a list with entries of type `<List<Vertex<T>>`.
class GraphCrawler<T> {
  GraphCrawler({
    @required this.edges,
  });

  /// Function returning a list of edge vertices or an empty list.
  /// It must never return `null`.
  final Edges<T> edges;

  /// Returns all paths from [start] vertex to [target] vertex.
  ///
  /// Note: The paths returned may include cycles if the graph is not acyclic.
  ///
  /// The algorithm keeps track of the edges already walked to avoid an
  /// infinite loop when encountering a cycle.
  List<List<Vertex<T>>> paths(Vertex<T> start, Vertex<T> target) {
    final _pathList = <List<Vertex<T>>>[];
    final _queue = Queue<Vertex<T>>();

    /// Add [this.target] to [path] and appends the result to [_paths].
    void _addPath(List<Vertex<T>> path) {
      // Add target vertex.
      path.add(target);
      _pathList.add(path);
    }

    /// Recursive function that crawls the graph defined by
    /// the function [edges] and records any path from [start] to [target].
    void _crawl(Vertex<T> start, Vertex<T> target) {
      _queue.addLast(start);
      for (final vertex in edges(start)) {
        //print('$start:${start.id} -> $vertex:${vertex.id}');
        //sleep(Duration(seconds: 1));
        if (vertex == target) {
          //print('|=======> Found target: recording result: $_queue');
          _addPath(_queue.toList());
        } else {
          // 'containts $vertex: ${start._visited.contains(vertex)}');
          if (start._visited.contains(vertex)) {
            //print('$start === has visited ===>  $vertex');
            continue;
          } else {
            start._visited.add(vertex);
            _crawl(vertex, target);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty && _queue.last != target) {
        // print('Stepping back');
        // print('$_queue: removing: ${_queue.last}');
        _queue.removeLast()._visited.clear();
      }
    }

    _crawl(start, target);

    // Clear visited vertices to make _crawl() idempotent.
    for (final vertex in _queue) {
      vertex._visited.clear();
    }

    return _pathList;
  }
}
