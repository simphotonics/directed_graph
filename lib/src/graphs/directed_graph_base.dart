import 'dart:collection' show HashMap, HashSet, LinkedHashSet, Queue;
import 'dart:math';

import 'package:collection/collection.dart' show PriorityQueue;
import 'package:directed_graph/src/extensions/sort.dart';
import 'package:lazy_memo/lazy_memo.dart';
import 'package:quote_buffer/quote_buffer.dart';

import 'graph_crawler.dart';

const int cyclicMarker = -1;

bool isSubType<S, T>() => <S>[] is List<T>;

/// Abstract base class of a directed graph.
abstract class DirectedGraphBase<T extends Object> extends Iterable<T> {
  /// Super constructor of objects extending `DirectedGraphBase`.
  /// * `comparator`: A function with signature `int Function(T a, T b)`
  /// used to sort vertices.
  DirectedGraphBase(Comparator<T>? comparator) : _comparator = comparator {
    if (comparator == null && isComparable) {
      _comparator = (T left, T right) =>
          (left as Comparable<T>).compareTo(right);
    }
  }

  /// Returns the shortest path from the vertex [start] to the vertex [target].
  /// * Returns an empty list if [target] is not reachable from [start].
  List<T> shortestPath(T start, T target) => crawler.path(start, target);

  /// Returns a map containing the shortest paths from
  /// [start] to each reachable vertex.
  /// The map keys represent the set of vertices reachable from [start].
  Map<T, Iterable<T>> shortestPaths(T start) => crawler.shortestPaths(start);

  bool get isComparable {
    if (Iterable<T>.empty() is Iterable<Comparable<T>>) {
      return true;
    } else {
      return false;
    }
  }

  /// The comparator used to sort vertices.
  Comparator<T>? _comparator;

  /// Returns the comparator used to sort graph vertices.
  Comparator<T>? get comparator => _comparator;

  /// Returns the inverse of [comparator]. Returns `null` if the graph has
  /// no comparator.
  Comparator<T>? get inverseComparator =>
      hasComparator ? (T v1, T v2) => -_comparator!(v1, v2) : null;

  /// Sets the comparator used to sort graph vertices.
  set comparator(Comparator<T>? comparator) {
    _comparator = comparator;
    _sortedVertices.updateCache();
  }

  /// Returns `true` if [comparator] is not null.
  bool get hasComparator => _comparator != null;

  /// Marks cached variables as stale.
  /// This method is called every time vertices or edges
  /// are *added* or *removed* from the graph.
  ///
  /// After calling this method
  /// all cached variables will be recalculated when next accessed.
  void updateCache() {
    _outDegreeMap.updateCache();
    _inDegreeMap.updateCache();
    _sortedVertices.updateCache();
    _isAcyclic.updateCache();
    _cycleVertex.updateCache();
  }

  /// Caches the sorted vertices.
  late final LazySet<T> _sortedVertices = LazySet<T>(
    () => vertices.toSet()..sort(comparator),
  );

  /// Caches the Boolean [isAcyclic].
  late final Lazy<bool> _isAcyclic = Lazy<bool>(
    () => (_cycleVertex() == null) ? true : false,
  );

  /// Returns true if the graph is a directed acyclic graph.
  bool get isAcyclic => _isAcyclic();

  /// Returns and caches a vertex that forms part of a cycle if
  /// the graph is cyclic and `null` otherwise.
  late final Lazy<T?> _cycleVertex = Lazy(() => _findCycleVertex());

  /// Returns the first vertex detected that forms part of a cycle if
  /// the graph is cyclic and `null` otherwise.
  ///
  /// Note: Use the function [cycle] to access a list of vertices
  /// that form a cyclic path.
  T? get cycleVertex => _cycleVertex();

  /// Returns an `Iterable<T>` of all vertices.
  Iterable<T> get vertices;

  /// Returns an set containing all vertices sorted using [comparator].
  /// If [comparator] is `null` this getter returns the original
  /// unsorted set of vertices.
  Set<T> get sortedVertices => _sortedVertices();

  /// Returns the vertices connected to `vertex`.
  Iterable<T> edges(T vertex);

  /// Returns `true` if there is an edge pointing from
  /// [source] to [target]. Returns `False` otherwise.
  bool edgeExists(T source, T target);

  /// Returns `true` if `vertex` is a graph vertex.
  /// Returns `false` otherwise.
  bool vertexExists(T vertex);

  /// Returns a mapping between vertex and number of
  /// outgoing connections.
  late final _outDegreeMap = LazyMap<T, int>(() {
    final map = <T, int>{};
    for (final vertex in sortedVertices) {
      map[vertex] = edges(vertex).length;
    }
    return map;
  });

  /// Returns a mapping between vertex and number of
  /// outgoing connections.
  Map<T, int> get outDegreeMap => _outDegreeMap();

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  late final _inDegreeMap = LazyMap<T, int>(() {
    var map = <T, int>{};
    for (final vertex in sortedVertices) {
      // The map entry might already exist if vertex is connected to a
      // previously encountered vertex.
      map[vertex] ??= 0;
      for (final connectedVertex in edges(vertex)) {
        map[connectedVertex] = (map[connectedVertex] ?? 0) + 1;
      }
    }
    return map;
  });

  /// Returns a mapping between vertex and number of
  /// incoming connections.
  Map<T, int> get inDegreeMap => _inDegreeMap();

  /// The graph crawler of this graph.
  late final GraphCrawler<T> crawler = GraphCrawler<T>(edges);

  /// Returns an iterable containing all vertices that are reachable from
  /// vertex [start].
  Set<T> reachableVertices(T start) {
    return crawler.tree(start).map<T>((branch) => branch.last).toSet();
  }

  /// Returns the shortest detected path from [start] to [target]
  /// including cycles.
  /// * Returns an empty list if no path was found.
  /// * To exclude cycles use the method `shortestPath(start, target)`.
  List<T> path(T start, T target) => crawler.path(start, target);

  /// Returns all paths from [start] to [target]
  /// including cycles.
  /// * Returns an empty list if no path was found.
  /// * To exclude cycles and list only the shortest paths
  ///   use the method `shortestPaths(start, target)`.
  List<List<T>> paths(T start, T target) => crawler.paths(start, target);

  /// Returns the first cycle detected or an empty list
  /// if the graph is acyclic.
  ///
  /// Note: A cycle starts and ends at
  /// the same vertex while inner vertices are distinct.
  List<T> cycle() {
    // Find a cycle.
    final start = cycleVertex;
    if (start == null) {
      return <T>[];
    } else {
      return crawler.path(start, start);
    }
  }

  /// Returns the first vertex detected
  /// that is part of a cycle.
  ///
  /// Returns `null` if the graph is acyclic.
  T? _findCycleVertex() {
    // Start vertex of the cycle.
    T? start;
    final temp = HashSet<T>();
    final perm = HashSet<T>();
    // Marks [this] graph as acyclic.
    var isCyclic = false;
    // Recursive function
    void visit(T vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // _Vertex has permanent mark.
      // => This vertex and its neighbouring
      //    vertices have already been visited.
      if (perm.contains(vertex)) return;
      // A cycle has been detected. Mark graph as acyclic.
      if (temp.contains(vertex)) {
        start = vertex;
        isCyclic = true;
        return;
      }
      // Temporary mark. Marks current vertex as visited.
      temp.add(vertex);
      for (final connectedVertex in edges(vertex)) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      perm.add(vertex);
    }

    // Main loop
    for (final vertex in sortedVertices) {
      if (isCyclic) break;
      visit(vertex);
    }
    return start;
  }

  /// Returns a list of type `List<Set<T>>` if the graph is acyclic or `null`
  /// otherwise.
  ///
  /// * The first entry contains the
  /// source vertices of the graph, that is vertices with no inbound edges.
  /// Any acyclic graph must have at least one source vertex.
  /// * Subsequent entries contain the local source vertices of the reduced graph.
  /// The reduced graph is obtained by removing all vertices listed in
  /// previous entries from the original graph.
  ///
  /// * Note: Concatenating the entries of [localSources] in sequential order
  ///       results in a topological ordering of the graph vertices.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  List<Set<T>>? localSources() {
    final result = <Set<T>>[];

    final vertices = LinkedHashSet<T>.of(sortedVertices);
    final localInDegreeMap = Map<T, int>.of(inDegreeMap);

    var hasSources = false;
    var count = 0;

    // Note: In an acyclic directed graph at least one
    // vertex has outDegree zero.
    do {
      // Storing local sources.
      final sources = <T>{};

      // Find local sources.
      for (final vertex in vertices) {
        if (localInDegreeMap[vertex] == 0) {
          sources.add(vertex);
          ++count;
        }
      }

      // Add sources to result:
      if (sources.isNotEmpty) result.add(sources);

      // Simulate the removal of detected local sources.
      for (final source in sources) {
        for (final connectedVertex in edges(source)) {
          var inDegree = localInDegreeMap[connectedVertex]!;
          inDegree--;
          localInDegreeMap[connectedVertex] = inDegree;
        }
      }
      // Check if local sources were found.
      hasSources = sources.isNotEmpty;
      vertices.removeAll(sources);
    } while (hasSources);

    return (count == length) ? result : null;
  }

  /// Returns an ordered set of all vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * If a vertex comparator is specified, the sorting will be applied
  /// in addition to the topological order.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop renders a directed graph cyclic.
  /// * Based on Kahn's algorithm.
  Set<T>? reverseTopologicalOrdering({bool sorted = false}) {
    if (_comparator == null || !sorted) {
      return _topologicalOrdering()?..reverse();
    }

    final result = <T>{};

    // Get modifiable in-degree map.
    final localInDegreeMap = HashMap<T, int>.of(inDegreeMap);

    // Add all sources (vertices with inDegree == 0) to queue.
    // Using a list instead of a queue to enable sorting of [sources].
    //
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    // Note: Using a reverse comparator since the resulting order
    //of the vertices will be reversed.
    final sources = PriorityQueue<T>(inverseComparator);
    for (final vertex in vertices) {
      if (localInDegreeMap[vertex] == 0) {
        sources.add(vertex);
      }
    }
    // Initialize count of visited vertices.
    var count = 0;

    // Note: In an acyclic directed graph at least
    // one vertex has outDegree zero.
    while (sources.isNotEmpty) {
      result.add(sources.removeFirst());

      // Simulate removing the current vertex from the
      //   graph. => Connected vertices will have inDegree = inDegree - 1.
      for (final vertex in edges(result.last)) {
        var inDegree = localInDegreeMap[vertex]!;
        inDegree--;
        localInDegreeMap[vertex] = inDegree;

        // Add new local source vertices of the remaining graph to the queue.
        if (inDegree == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }

    result.reverse();
    return (count == length) ? result : null;
  }

  /// Returns an ordered set of all vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * If a vertex comparator is specified, the sorting will be applied
  /// in addition to the topological order.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop renders a directed graph cyclic.
  /// * Based on Kahn's algorithm.
  Set<T>? topologicalOrdering({bool sorted = false}) {
    if (_comparator == null || !sorted) return _topologicalOrdering();

    final result = <T>{};

    // Get modifiable in-degree map.
    final localInDegreeMap = HashMap<T, int>.of(inDegreeMap);

    // Add all sources (vertices with inDegree == 0) to queue.
    // Using a list instead of a queue to enable sorting of [sources].
    //
    // Note: In an acyclic directed graph there is at least
    //       one vertex with inDegree equal to zero.
    final sources = PriorityQueue<T>(comparator);
    for (final vertex in vertices) {
      if (localInDegreeMap[vertex] == 0) {
        sources.add(vertex);
      }
    }
    // Initialize count of visited vertices.
    var count = 0;

    // Note: In an acyclic directed graph at least
    // one vertex has outDegree zero.
    while (sources.isNotEmpty) {
      result.add(sources.removeFirst());

      // Simulate removing the current vertex from the
      //   graph. => Connected vertices will have inDegree = inDegree - 1.
      for (final vertex in edges(result.last)) {
        var inDegree = localInDegreeMap[vertex]!;
        inDegree--;
        localInDegreeMap[vertex] = inDegree;

        // Add new local source vertices of the remaining graph to the queue.
        if (inDegree == 0) {
          sources.add(vertex);
        }
      }
      // Increment count of visited vertices.
      count++;
    }
    return (count == length) ? result : null;
  }

  /// Returns a set containing all graph vertices in topological order.
  /// * For every directed edge: (vertex1 -> vertex2), vertex1
  /// is listed before vertex2.
  ///
  /// * Note: There is no topological ordering if the
  /// graph is cyclic. In that case the function returns `null`.
  /// * Any self-loop (e.g. vertex1 -> vertex1) renders a directed graph cyclic.
  /// * Based on a depth-first search algorithm (Cormen 2001, Tarjan 1976).
  Set<T>? _topologicalOrdering() {
    final queue = Queue<T>();
    final perm = HashSet<T>();
    final temp = HashSet<T>();

    // Marks graph as cyclic.
    var isCyclic = false;

    // Recursive function
    void visit(T vertex) {
      // Graph is not a Directed Acyclic Graph (DAG).
      // Terminate iteration.
      if (isCyclic) return;

      // Vertex has permanent mark.
      // => This vertex and its neighbouring vertices
      // have already been visited.
      if (perm.contains(vertex)) return;

      // A cycle has been detected. Mark graph as acyclic.
      if (temp.contains(vertex)) {
        isCyclic = true;
        return;
      }

      // Temporary mark. Marks current vertex as visited.
      temp.add(vertex);
      for (final connectedVertex in edges(vertex)) {
        visit(connectedVertex);
      }
      // Permanent mark, indicating that there is no path from
      // neighbouring vertices back to the current vertex.
      // We tried all options.
      perm.add(vertex);
      queue.addFirst(vertex);
    }

    // Main loop
    // Note: Iterating in reverse order of [vertices]
    // (approximately) preserves the
    // sorting of vertices (on top of the topological sorting.)
    // For a sorted topological ordering use
    // the getter: [topologicalOrdering(sorted: true)].
    //
    // Iterating in normal order of [vertices] yields a different
    // valid topological sorting.
    for (final vertex in sortedVertices.toList().reversed) {
      visit(vertex);
      if (isCyclic) break;
    }

    // Return null if graph is not a DAG.
    return (isCyclic) ? null : queue.toSet();
  }

  /// Returns a list of strongly connected components (SCC). The vertices
  /// are sorted if [sorted] is set to `true` and a
  /// comparator is provided. The graph [comparator] is used as a fallback.
  /// * If vertices a and b belong to the same strongly connected component,
  /// then vertex a is reachable from b and vertex b is reachable from a.
  /// * Uses Tarjans algorithm:
  /// (https://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm#References)
  /// * If a graph is acyclic, each strongly connected component
  /// consists of a single vertex and the vertices are listed in *inverse*
  /// topological order.(The reverse is only true if the graph does not
  /// contains any self-loops, that is edges pointing from a vertex to itself.)
  List<Set<T>> stronglyConnectedComponents({
    bool sorted = false,
    Comparator<T>? comparator,
  }) {
    final queue = Queue<T>();
    var index = 0;
    final result = <Set<T>>[];

    final lowLink = HashMap<T, int>();
    final indices = HashMap<T, int>();

    void strongConnect(T vertex) {
      lowLink[vertex] = index;
      indices[vertex] = index;
      index++;
      queue.addLast(vertex);

      for (final connectedVertex in edges(vertex)) {
        if (!indices.containsKey(connectedVertex)) {
          strongConnect(connectedVertex);
          lowLink[vertex] = min(lowLink[vertex]!, lowLink[connectedVertex]!);
        } else if (queue.contains(connectedVertex)) {
          lowLink[vertex] = min(lowLink[vertex]!, indices[connectedVertex]!);
        }
      }

      // Check if vertex is a root node:
      if (lowLink[vertex] == indices[vertex]) {
        final scc = <T>{};
        late T componentVertex;
        do {
          componentVertex = queue.removeLast();
          scc.add(componentVertex);
        } while (vertex != componentVertex);
        result.add(scc);
      }
    }

    void strongConnectSorted(T vertex, {Comparator<T>? comparator}) {
      lowLink[vertex] = index;
      indices[vertex] = index;
      index++;
      queue.addLast(vertex);

      for (final connectedVertex in edges(vertex)) {
        if (!indices.containsKey(connectedVertex)) {
          strongConnectSorted(connectedVertex);
          lowLink[vertex] = min(lowLink[vertex]!, lowLink[connectedVertex]!);
        } else if (queue.contains(connectedVertex)) {
          lowLink[vertex] = min(lowLink[vertex]!, indices[connectedVertex]!);
        }
      }

      // Check if vertex is a root node:
      if (lowLink[vertex] == indices[vertex]) {
        final scc = PriorityQueue<T>(comparator);
        late T componentVertex;
        do {
          componentVertex = queue.removeLast();
          scc.add(componentVertex);
        } while (vertex != componentVertex);
        result.add(scc.toSet());
      }
    }

    switch (sorted) {
      case true:
        for (final vertex
            in vertices.toList()..sort(comparator ?? this.comparator)) {
          if (!indices.containsKey(vertex)) {
            strongConnectSorted(
              vertex,
              comparator: comparator ?? this.comparator,
            );
          }
        }
        return result;
      default:
        for (final vertex in vertices) {
          if (!indices.containsKey(vertex)) {
            strongConnect(vertex);
          }
        }
        return result;
    }
  }

  /// Returns a set containing the elements of [vertices]
  /// in quasi-topological insertion order.
  /// * [vertices] must be a subset of the graph vertices. If any vertex in
  /// [vertices] does not belong to the graph, `null` is returned.
  /// * Note: If A and B are any two elements of [vertices],
  /// and there is a path [A, ..., B], then there be no path [B, ..., A]
  ///  for a quasi-topological ordering to exists.
  /// * If sorted is set to
  /// `true` the vertices will be ordered using the graph [comparator] on top
  /// of the topological sort.
  Set<T>? quasiTopologicalOrdering(Set<T> vertices, {bool sorted = false}) {
    if (!sortedVertices.containsAll(vertices)) {
      return null;
    }

    final scc = stronglyConnectedComponents(
      sorted: sorted,
      comparator: inverseComparator,
    );

    final verticesInSameComponent = HashSet.of([]);
    bool isQuasiSortable = true;

    componentLoop:
    for (final component in scc) {
      // Start with an empty set when proceeding to the next component!
      verticesInSameComponent.clear();
      for (final vertex in vertices) {
        if (component.contains(vertex)) {
          verticesInSameComponent.add(vertex);
        }
        if (verticesInSameComponent.length > 1) {
          isQuasiSortable = false;
          break componentLoop;
        }
      }
    }

    if (isQuasiSortable) {
      final result = scc.fold(
        <T>[],
        (flattendList, component) =>
            flattendList
              ..addAll(component.where((vertex) => vertices.contains(vertex))),
      );
      return result.reversed.toSet();
    } else {
      return null;
    }
  }

  /// Returns a set containing the elements of [vertices]
  /// in reverse quasi topological insertion order if there is not
  /// mutual connection
  /// between any two elements of [vertices].
  ///
  /// * [vertices] must be a subset of the graph vertices. If any vertex in
  /// [vertices] does not belong to the graph, `null` is returned.
  /// * If sorted is set to
  /// `true` the vertices will be ordered using the graph [comparator] on top
  /// of the reverse topological sort.
  Set<T>? reverseQuasiTopologicalOrdering(
    Set<T> vertices, {
    bool sorted = false,
  }) {
    if (!sortedVertices.containsAll(vertices)) {
      return null;
    }

    final scc = stronglyConnectedComponents(
      sorted: sorted,
      comparator: comparator,
    );

    final verticesInSameComponent = HashSet.of([]);
    bool isQuasiSortable = true;

    componentLoop:
    for (final component in scc) {
      // Start with an empty set when proceeding to the next component!
      verticesInSameComponent.clear();
      for (final vertex in vertices) {
        if (component.contains(vertex)) {
          verticesInSameComponent.add(vertex);
        }
        if (verticesInSameComponent.length > 1) {
          isQuasiSortable = false;
          break componentLoop;
        }
      }
    }

    if (isQuasiSortable) {
      final result = scc.fold(
        <T>[],
        (flattendList, component) =>
            flattendList
              ..addAll(component.where((vertex) => vertices.contains(vertex))),
      );
      return result.toSet();
    } else {
      return null;
    }
  }

  /// Returns the number of outgoing directed edges for [vertex].
  /// * Note: Returns `null` if `vertex` does not belong to the graph.
  int? outDegree(T vertex) {
    return vertexExists(vertex) ? edges(vertex).length : null;
  }

  /// Returns the number of incoming directed edges for [vertex].
  ///
  /// Returns `null` if `vertex` is not a graph vertex.
  int? inDegree(T vertex) {
    if (!vertexExists(vertex)) {
      return null;
    }
    var inDegree = 0;
    for (final start in vertices) {
      if (edgeExists(start, vertex)) {
        ++inDegree;
      }
    }
    return inDegree;
  }

  /// Returns a String representation of the graph.
  ///
  /// Vertices of type [String] are *quoted* using
  /// `QuoteBuffer` an extension on [StringBuffer] so that one can
  /// copy terminal output and paste it as valid source code representing
  /// a map.
  @override
  String toString() {
    if (isEmpty) return '{}';
    var b = StringBuffer();
    final isString = (first is String);
    b.writeln('{');
    for (final vertex in vertices) {
      b.write(' ');
      isString ? b.writeQ(vertex) : b.write(vertex);
      b.write(': ');
      b.write('{');
      isString ? b.writeAllQ(edges(vertex)) : b.writeAll(edges(vertex), ', ');
      b.write('},');
      b.writeln('');
    }
    b.write('}');
    return b.toString();
  }
}
