import 'package:directed_graph/directed_graph.dart';

void main() {
  int comparator(String s1, String s2) => s1.compareTo(s2);
  int inverseComparator(String s1, String s2) => -comparator(s1, s2);

  // Constructing a graph from vertices.

  final graph = DirectedGraph<String>({
    'a': {'b', 'h', 'c', 'e'},
    'b': {'h'},
    'c': {'h', 'g'},
    'd': {'e', 'f'},
    'e': {'g'},
    'f': {'i'},
    //g': {'a'},
    'i': {'l'},
    'k': {'g', 'f'},
  }, comparator: comparator);

  print('Example Directed Graph...');
  print('graph.toString():');
  print(graph);

  print('\nIs Acylic:');
  print(graph.isAcyclic);

  print('\nStrongly connected components:');
  print(graph.stronglyConnectedComponents());

  print('\nLocal sources:');
  print(graph.localSources());

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

  print('\nReverse Topological Ordering, sorted: true');
  print(graph.reverseTopologicalOrdering(sorted: true));

  print('\nLocal Sources:');
  print(graph.localSources());

  print('\nAdding edges: i -> k and i -> d');

  // Add edge to render the graph cyclic
  graph.addEdge('i', 'k');
  //graph.addEdge('l', 'l');
  graph.addEdge('i', 'd');

  print('\nCyclic graph:');
  print(graph);

  print('\nCycle:');
  print(graph.cycle());

  print('\nCycle vertex:');
  print(graph.cycleVertex);

  print('\ngraph.isAcyclic: ');
  print(graph.isAcyclic);

  print('\nShortest Paths:');
  print(graph.shortestPaths('a'));

  print('\nEdge exists: a->b');
  print(graph.edgeExists('a', 'b'));

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

  print('\nQuasi-Topological Ordering:');
  print(graph.quasiTopologicalOrdering({'d', 'e', 'a', 'g'}));

  print('\nQuasi-Topological Ordering, sorted:');
  print(graph.quasiTopologicalOrdering({'d', 'e', 'a', 'g'}, sorted: true));

  print('\nReverse-Quasi-Topological Ordering, sorted:');
  print(graph.reverseQuasiTopologicalOrdering({'d', 'e', 'a', 'g'}, sorted: true));
}
