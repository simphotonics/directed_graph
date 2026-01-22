import 'directed_graph.dart';

/// Graph with bidirected edges represented by a directed graph
/// with symmetric edges.
class BidirectedGraph<T extends Object> extends DirectedGraph<T> {
  BidirectedGraph(super.edges, {super.comparator}) {
    // Render graph symmetric:
    _symmetrize();
  }

  /// Constructs a bidirected graph from a directed graph.
  BidirectedGraph.from(DirectedGraph<T> graph)
      : super(graph.data, comparator: graph.comparator) {
    _symmetrize();
  }

  /// Constructs the bidirected transitive closure of a graph.
  /// * Note: The input graph can be a directed graph or a bidirected graph.
  factory BidirectedGraph.transitiveClosure(DirectedGraph<T> graph) {
    final tc = DirectedGraph.transitiveClosure(graph);
    return BidirectedGraph<T>.from(tc);
  }

  @override
  void addEdge(T vertex, T connectedVertex) {
    super.addEdge(vertex, connectedVertex);
    super.addEdge(connectedVertex, vertex);
  }

  @override
  void addEdges(T vertex, Set<T> connectedVertices) {
    super.addEdges(vertex, connectedVertices);
    for (final connectedVertex in connectedVertices) {
      super.addEdges(connectedVertex, {vertex});
    }
  }

  /// Removes edges (connections) pointing from [vertex]
  /// to [connectedVertices].
  /// * Note: Does not remove the vertices.
  @override
  void removeEdges(T vertex, Set<T> connectedVertices) {
    super.removeEdges(vertex, connectedVertices);
    for (final connectedVertex in connectedVertices) {
      super.removeEdges(connectedVertex, {vertex});
    }
  }

  /// Removes edges ending at [vertex] from the graph.
  @override
  void removeIncomingEdges(T vertex) {
    super.removeIncomingEdges(vertex);
    removeEdges(vertex, edges(vertex).toSet());
  }

  @override
  void remove(T vertex) {
    removeIncomingEdges(vertex);
    super.remove(vertex);
  }

  /// Renders the graph symmetric by adding a symmetric edge
  /// for each existing graph edge.
  void _symmetrize() {
    for (final vertex in vertices) {
      for (final connectedVertex in edges(vertex)) {
        if (edges(connectedVertex).contains(vertex)) continue;
        addEdges(connectedVertex, {vertex});
      }
    }
  }
}
