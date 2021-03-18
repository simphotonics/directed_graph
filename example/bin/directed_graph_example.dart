import 'package:directed_graph/directed_graph.dart';
// To run this program navigate to
// the folder 'directed_graph/example'
// in your terminal and type:
//
// # dart bin/directed_graph_example.dart
//
// followed by enter.
void main() {
  int comparator(String s1, String s2) => s1.compareTo(s2);
  int inverseComparator(String s1, String s2) => -comparator(s1, s2);

  // Constructing a graph from vertices.
  final graph = DirectedGraph<String>(
    {
      'a': {'b', 'h', 'c', 'e'},
      'b': {'h'},
      'c': {'h', 'g'},
      'd': {'e', 'f'},
      'e': {'g'},
      'f': {'i'},
      'i': {'l'},
      'k': {'g', 'f'}
    },
    comparator: comparator,
  );

  print('Example Directed Graph...');
  print('graph.toString():');
  print(graph);

  print('\nIs Acylic:');
  print(graph.isAcyclic);

  print('\nStrongly connected components:');
  print(graph.stronglyConnectedComponents);

  print('\nShortestPath(d, l):');
  //print(graph.shortestPath('d', 'l');

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
  print(graph.sortedTopologicalOrdering);

  print('\nTopological Ordering:');
  print(graph.topologicalOrdering);

  print('\nLocal Sources:');
  print(graph.localSources);

  // Add edge to render the graph cyclic
  graph.addEdges('i', {'k'});
  graph.addEdges('l', {'l'});
  graph.addEdges('i', {'d'});

  print('\nCycle:');
  print(graph.cycle);

  print('\nShortest Paths:');
  print(graph.shortestPaths('a'));
}
