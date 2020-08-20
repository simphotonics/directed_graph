/// Dart implementation of a directed graph.
/// Provides methods to
/// * add/remove edges,
/// * check if the graph is acyclic,
/// * retrieve cycles,
/// * retrieve a list of vertices in topological order.
library directed_graph;

import 'dart:collection' show HashSet, Queue, SplayTreeMap;

// import 'package:graphs/graphs.dart' as graphs;

/// Function returning a list of edge vertices.
/// If a vertex has no neighbours it should return
/// an empty list.
///
/// Note: The function must never return null.
typedef Edges<T> = List<T> Function(T vertex);

/// _Vertex mark used by sorting algorithms.
enum _Mark { PERMANENT, TEMPORARY }

/// Generic object representing a vertex in a graph.
/// Holds data of type [T].
class Vertex<T> {
  /// _Vertex id.
  final int id;

  /// _Vertex data of type [T].
  final T data;

  /// _Vertex counter.
  static int _counter = 0;

  /// Creates a vertex holding generic data of type [T].
  Vertex._(this.data) : id = ++_counter;

  /// Returns the number of vertices connected by
  /// outgoing directed edges.
  int get inDegree => inConnections.length;

  /// Return the number of vertices connected by incoming
  /// directed edges.
  int get outDegree => outConnections.length;

  @override
  bool operator ==(Object other) => other is Vertex<T> && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$data';

  /// Private field used by DFS algorithms.
  _Mark? _mark;

  /// Outgoing vertices
  final outConnections = HashSet<Vertex<T>>();

  /// Incoming directed edges
  final inConnections = HashSet<Vertex<T>>();
}

/// Generic directed graph storing vertices of type `T`.
/// * `T` should be usable as map keys.
class DirectedGraph<T> extends Iterable {
  /// Constructs a directed graph from a map of type `Map<T, List<T>>`.
  DirectedGraph(
    Map<T, List<T>> data, {
    Comparator<T>? comparator,
  })  : _comparator = comparator,
        _vertexMap = SplayTreeMap<T, Vertex<T>>(comparator) {
    // Transform data to vertices.
    data.forEach((key, value) {
      _vertexMap[key] = Vertex<T>._(key);
      for (final t in value) {
        _vertexMap[t] ??= Vertex<T>._(t);
      }
    });
    // Construct the map of graph edges.
    data.forEach((key, value) {
      for (final t in value) {
        _vertexMap[key]!.outConnections.add(_vertexMap[t]!);
        _vertexMap[t]!.inConnections.add(_vertexMap[key]!);
      }
    });
  }

  /// Factory constructor that returns a copy of [directedGraph]
  /// containing new instances of vertices.
  /// - Note: _Vertex data is shallow copied.
  factory DirectedGraph.from(DirectedGraph<T> directedGraph) => DirectedGraph(
        directedGraph.data,
        comparator: directedGraph.comparator,
      );

  /// Maps each distinct object of type `T` to a vertex of type `Vertex<T>`.
  SplayTreeMap<T, Vertex<T>> _vertexMap;

  /// The comparator used to sort vertices.
  Comparator<T>? _comparator;

  /// Returns a list of graph vertices.
  Iterable<Vertex<T>> get vertices => _vertexMap.values;

  /// Returns the comparator used to sort graph vertices.
  Comparator<T>? get comparator => _comparator;

  /// Sets the comparator used to sort graph vertices.
  set comparator(Comparator<T>? comparator) {
    _comparator = comparator;
    if (comparator == null) {
      _vertexMap = SplayTreeMap.from(_vertexMap);
    }
    _vertexMap = SplayTreeMap.from(_vertexMap, comparator);
  }

  /// Returns the underlying graph data as a map of type `Map<T, List<T>>`.
  Map<T, List<T>> get data {
    final data = <T, List<T>>{};
    for (final vertex in _vertexMap.values) {
      data[vertex.data] =
          vertex.outConnections.map<T>((item) => item.data).toList();
    }
    return data;
  }

  /// Returns list of vertices connected to [vertex].
  /// Note: Mathematically, an edge is an ordered pair
  /// (vertex, connected-vertex).
  Iterable<T> edges(T vertex) =>
      _vertexMap[vertex]?.outConnections.map<T>((item) => item.data) ?? <T>[];

  /// Adds edges (connections) pointing from [vertex] to [connectedVertices].
  void addEdges(T vertex, List<T> connectedVertices) {
    // Add vertices to graph.
    _vertexMap[vertex] ??= Vertex._(vertex);
    for (final connectedVertex in connectedVertices) {
      _vertexMap[connectedVertex] ??= Vertex._(connectedVertex);
      _vertexMap[vertex]!.outConnections.add(_vertexMap[connectedVertex]!);
      _vertexMap[connectedVertex]!.inConnections.add(_vertexMap[vertex]!);
    }
  }

  /// Removes edges (connections) pointing from [vertex] to [connectedVertices].
  /// If connectedVertices is not specified all outgoing
  /// edges are removed from the graph.
  void removeEdges(T vertex, [List<T>? connectedVertices]) {
    if (_vertexMap[vertex] == null) return;
    // Remove all edges.
    if (connectedVertices == null) {
      _vertexMap[vertex]!
          .outConnections
          .forEach((item) => item.inConnections.remove(vertex));
      _vertexMap[vertex]!.outConnections.clear();
      return;
    }
    // Remove specified edges.
    for (final connectedVertex in connectedVertices) {
      if (_vertexMap[vertex]!.outConnections.remove(connectedVertex)) {
        _vertexMap[connectedVertex]!.inConnections.remove(vertex);
      }
    }
  }

  /// Removes edges ending at [vertex] from the graph.
  void removeIncomingEdges(T vertex) {
    if (_vertexMap[vertex] == null) return;
    for (final sourceVertex in _vertexMap[vertex]!.inConnections) {
      sourceVertex.outConnections.remove(_vertexMap[vertex]);
    }
    _vertexMap[vertex]!.inConnections.clear();
  }

  /// Completely remove [vertex] from the graph, including outgoing
  /// and incoming edges.
  void remove(T vertex) {
    if (_vertexMap[vertex] == null) return;
    removeEdges(vertex);
    removeIncomingEdges(vertex);
    _vertexMap.remove(vertex);
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
    final result = <List<Vertex<T>>>[];

    // Get modifiable in-degree map.
    final _inDegreeMap = inDegreeMap;

    // Get modifiable list of the graph vertices
    var vertices = this.vertices;

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
      for (final vertex in vertices) {
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
        for (final connectedVertex in source.outConnections) {
          _inDegreeMap[connectedVertex] = inDegreeMap[connectedVertex]! - 1;
        }
      }
      // Check if local source were found.
      hasSources = sources.isNotEmpty;

      // Replacing vertices with remaining vertices.
      vertices = remainingVertices;
    } while (hasSources);

    return result
        .map<List<T>>(
            (vertexList) => vertexList.map<T>((vertex) => vertex.data).toList())
        .toList();

    return (count == _inDegreeMap.length)
        ? result
            .map<List<T>>((vertexList) =>
                vertexList.map<T>((vertex) => vertex.data).toList())
            .toList()
        : null;
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

    int vertexComparator(Vertex<T> v1, Vertex<T> v2) =>
        comparator!(v1.data, v2.data);

    final result = <Vertex<T>>[];

    // Get modifiable in-degree map.
    final inDegreeMap = this.inDegreeMap;

    // Add all sources (vertices with inDegree == 0) to queue.
    // Using a list instead of a queue to enable sorting of [sources].
    //
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    final sources = <Vertex<T>>[];
    for (final vertex in vertices) {
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
      sources.sort(vertexComparator);
      var current = sources.removeAt(0);
      result.add(current);

      // Simulate removing the current vertex from the
      //   graph. => Connected vertices with have inDegree = inDegree - 1.
      for (final vertex in current.outConnections) {
        inDegreeMap[vertex] = inDegreeMap[vertex]! - 1;

        // Add new local source vertices of the remaining graph to the queue.
        if (inDegreeMap[vertex] == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }
    return (count != vertices.length)
        ? null
        : result.map<T>((item) => item.data).toList();
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
    final queue = Queue<Vertex<T>>();

    // Marks [this] graph as cyclic.
    var isCyclic = false;

    // Recursive function
    void visit(Vertex<T> vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // _Vertex has permanent mark.
      // => This vertex and its neighbouring vertices
      //    have already been visited.
      if (vertex._mark == _Mark.PERMANENT) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (vertex._mark == _Mark.TEMPORARY) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      vertex._mark = _Mark.TEMPORARY;
      for (final connected_Vertex in vertex.outConnections) {
        visit(connected_Vertex);
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
    for (final current in vertices) {
      if (isCyclic) break;
      visit(current);
    }

    // Clearing vertex marks.
    // Important! Otherwise method won't be idempotent.
    for (final vertex in vertices) {
      vertex._mark = null;
    }

    // Return null if graph is not a DAG.
    return (isCyclic) ? null : queue.map<T>((item) => item.data).toList();
  }

  /// Returns `List<_Vertex<T>>`, a list of all vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// * Based on a depth-first search algorithm (Cormen 2001, Tarjan 1976).
  List<T>? get topologicalOrderingII {
    final queue = Queue<Vertex<T>>();

    final temp = HashSet<int>();
    final perm = HashSet<int>();

    // Marks graph as cyclic.
    var isCyclic = false;

    // Recursive function
    void visit(Vertex<T> vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // _Vertex has permanent mark.
      // => This vertex and its neighbouring vertices
      // have already been visited.
      if (perm.contains(vertex.id)) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (temp.contains(vertex.id)) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      temp.add(vertex.id);
      for (final connected_Vertex in vertex.outConnections) {
        visit(connected_Vertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      // We tried all options.
      perm.add(vertex.id);
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
    for (final current in vertices.toList().reversed) {
      if (isCyclic) break;
      visit(current);
    }

    // Return null if graph is not a DAG.
    return (isCyclic) ? null : queue.map<T>((item) => item.data).toList();
  }

  /// Returns the first cycle detected or an empty list
  /// if the graph is acyclic.
  ///
  /// Note: A cycle is a path that starts and ends with
  /// the same vertex.
  List<T> get cycle {
    /// Start vertex of the cycle.
    Vertex<T>? start;

    // Marks [this] graph as acyclic.
    var isCyclic = false;

    // Recursive function
    void visit(Vertex<T> vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // _Vertex has permanent mark.
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
      for (final connected_Vertex in vertex.outConnections) {
        visit(connected_Vertex);
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
      return path(start!.data, start!.data);
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
  List<T> findCycle() {
    List<T> cycle;

    // Main loop
    for (final vertex in vertices) {
      if (vertex.inDegree == 0) continue;
      if (vertex.outDegree == 0) continue;
      cycle = path(vertex.data, vertex.data);
      if (cycle.isNotEmpty) return cycle;
    }
    return [];
  }

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<Vertex<T>, int> get inDegreeMap {
    final map = <Vertex<T>, int>{};
    for (final vertex in vertices) {
      map[vertex] = vertex.inConnections.length;
    }
    return map;
  }

  /// Returns the number of incoming directed edges for [vertex].
  int? inDegree(T vertex) {
    return _vertexMap[vertex]?.inConnections.length;
  }

  /// Returns the number of outgoing directed edges for [vertex].
  int? outDegree(T vertex) {
    return _vertexMap[vertex]?.outConnections.length;
  }

  /// Returns a mapping between vertex and number of
  /// outgoing connections (edges).
  Map<Vertex<T>, int> get outDegreeMap {
    final map = <Vertex<T>, int>{};
    for (final vertex in vertices) {
      map[vertex] = vertex.outConnections.length;
    }
    return map;
  }

  /// Returns a string representation of the graph.
  @override
  String toString() {
    var b = StringBuffer();
    b.writeln('{');
    for (final vertex in vertices) {
      b.write(' $vertex: ');
      b.write('[');
      b.writeAll(vertex.outConnections, ', ');
      b.write('],');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }

  /// Returns a `String` representation of the graph
  /// using the vertex `id` instead of the vertex `data`.
  String get displayStructure {
    var b = StringBuffer();
    b.writeln('{');
    for (var vertex in vertices) {
      b.write(' ${vertex.id}: ');
      b.write('[');
      b.writeAll(vertex.outConnections.map<int>((item) => item.id), ', ');
      b.write('],');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }

  @override
  Iterator<T> get iterator => _vertexMap.keys.iterator;

  /// Returns the first detected path from [start] to [target].
  List<T> path(T start, T target) {
    final _visited = <int, HashSet<int>>{};
    final _queue = Queue<Vertex<T>>();
    var path = <Vertex<T>>[];
    var pathFound = false;

    final startVertex = _vertexMap[start];
    final targetVertex = _vertexMap[target];

    if (startVertex == null || targetVertex == null) {
      return <T>[];
    }

    /// Recursive function that crawls the graph defined by
    /// `edges` and records the first path from [start] to [target].
    void _crawl(Vertex<T> startVertex, Vertex<T> targetVertex) {
      // Return if a path has already been found.
      if (pathFound) {
        return;
      }
      _queue.addLast(startVertex);
      for (final vertex in startVertex.outConnections) {
        if (vertex == targetVertex) {
          // Store result.
          path = List<Vertex<T>>.from(_queue);
          pathFound = true;
          return;
        } else {
          if (_visited[startVertex.id] == null) {
            _visited[startVertex.id] = HashSet();
            _visited[startVertex.id]!.add(vertex.id);
            _crawl(vertex, targetVertex);
          }
          if (_visited[startVertex.id]!.contains(vertex.id)) {
            continue;
          } else {
            _visited[startVertex.id]!.add(vertex.id);
            _crawl(vertex, targetVertex);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty) {
        _queue.removeLast();
      }
    }

    _crawl(startVertex, targetVertex);

    if (path.isEmpty) {
      return <T>[];
    } else {
      path.add(targetVertex);
      return path.map<T>((item) => item.data).toList();
    }
  }

  /// Returns the paths from [start] vertex to [target] vertex.
  ///
  /// * Each directed edge is walked only once.
  /// * The paths returned may include cycles if the graph is cyclic.
  /// * The algorithm keeps track of the edges already walked to avoid an
  ///    infinite loop when encountering a cycle.
  List<List<T>> paths(T start, T target) {
    final _visited = <int, HashSet<int>>{};
    final _pathList = <List<Vertex<T>>>[];
    final _queue = Queue<Vertex<T>>();
    final startVertex = _vertexMap[start];
    final targetVertex = _vertexMap[target];

    if (startVertex == null || targetVertex == null) {
      return <List<T>>[];
    }

    /// Adds [this.target] to [path] and appends the result to [_paths].
    void _addPath(List<Vertex<T>> path) {
      // Add target vertex.
      path.add(targetVertex);
      _pathList.add(path);
    }

    /// Recursive function that crawls the graph defined by
    /// the function [edges] and records any path from [start] to [target].
    void _crawl(Vertex<T> start, Vertex<T> target) {
      // print('-----------------------');
      // print('Queue: $_queue');
      // print('Start: ${start} => target: ${target}.');
      _queue.addLast(start);
      for (final vertex in start.outConnections) {
        // print('$start:${start.id} -> $vertex:${vertex.id}');
        // print('${start} -> ${vertex}');
        //stdin.readLineSync();
        //sleep(Duration(seconds: 2));
        if (vertex == target) {
          // print('|=======> Found target: recording '
          //     'result: $_queue');
          _addPath(_queue.toList());
        } else {
          if (_visited[start.id] == null) {
            _visited[start.id] = HashSet();
            _visited[start.id]!.add(vertex.id);
            _crawl(vertex, target);
          }
          if (_visited[start.id]!.contains(vertex.id)) {
            // print('${start} has visited ${vertex}');
            // print('Choose next vertex:');
            continue;
          } else {
            _visited[start.id]!.add(vertex.id);
            // print('$vertex added to visited.');
            _crawl(vertex, target);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty && _queue.last != target) {
        // print('Stepping back');
        // print('$_queue: removing: ${_queue.last}');
        // print('Clearing visited of ${_queue.last}: ${_queue.last._visited}');
        //_queue.removeLast()._visited.clear();
        _queue.removeLast();
      }
    }

    _crawl(startVertex, targetVertex);

    return _pathList
        .map<List<T>>(
          (vertexList) => vertexList.map<T>((vertex) => vertex.data).toList(),
        )
        .toList();
  }
}
