import 'package:directed_graph/directed_graph.dart';

void main() {
  int comparator(String s1, String s2) => s1.compareTo(s2);
  int inverseComparator(String s1, String s2) => -comparator(s1, s2);

  // Constructing a graph from vertices.

  final graph = DirectedGraph<String>({
    'k': {'i'},
    'e': {'g'},
    'd': {},
    'c': {'b'},
    'f': {},
    'g': {'e'},
    'i': {},
    'b': {'a'},
    'a': {},
  }, comparator: comparator);

  print('Example Directed Graph...');
  print('graph.toString():');
  print(graph);

  print('\nIs Acylic:');
  print(graph.isAcyclic);

  print('\nStrongly connected components:');
  print(graph.stronglyConnectedComponents());

  print('\nStrongly connected components, sorted:');
  print(
    graph.stronglyConnectedComponents(sorted: true, comparator: comparator),
  );

  print('\nStrongly connected components, sorted, inverse:');
  print(
    graph.stronglyConnectedComponents(
      sorted: true,
      comparator: inverseComparator,
    ),
  );

  print('\nshortestPath(d, l):');
  print(graph.shortestPath('d', 'l'));

  print('\nshortestPaths(a)');
  print(graph.shortestPaths('a'));

  print('\nInDegree(C):');
  print(graph.inDegree('c'));

  print('\nOutDegree(C)');
  print(graph.outDegree('c'));

  print('\nVertices sorted in lexicographical order:');
  print(graph.sortedVertices);

  print('\nVertices sorted in inverse lexicographical order:');
  graph.comparator = inverseComparator;
  print(graph.sortedVertices);
  graph.comparator = comparator;

  print('\nInDegreeMap:');
  print(graph.inDegreeMap);

  print('\nSorted Topological Ordering:');
  print(graph.topologicalOrdering(sorted: true));

  print('\nTopological Ordering:');
  print(graph.topologicalOrdering());

  print('\nReverse Topological Ordering:');
  print(graph.reverseTopologicalOrdering());

  print('\nQuasi-Topological Ordering:');
  print(graph.quasiTopologicalOrdering({'k', 'i', 'd'}));

  print('\nQuasi-Topological Ordering, sorted:');
  print(graph.quasiTopologicalOrdering({'k', 'i', 'd'}, sorted: true));

  print('\nReverse-Quasi-Topological Ordering, sorted:');
  print(graph.reverseQuasiTopologicalOrdering({'k', 'i', 'd'}, sorted: true));

  print('\nLocal Sources:');
  print(graph.localSources());

  // Add edge to render the graph cyclic
  graph.addEdges('i', {'k'});
  graph.addEdges('l', {'l'});
  graph.addEdges('i', {'d'});

  print('\nCycle:');
  print(graph.cycle());

  print('\nShortest Paths:');
  print(graph.shortestPaths('a'));

  print('\nEdge exists: a->b');
  print(graph.edgeExists('a', 'b'));
}
