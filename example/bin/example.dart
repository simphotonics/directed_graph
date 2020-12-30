import 'package:directed_graph/src/graphs/directed_graph.dart';
import 'package:directed_graph/src/utils/color_utils.dart';

// To run this program navigate to
// the folder 'directed_graph/example'
// in your terminal and type:
//
// # dart bin/example.dart
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

  print(magenta('Example Directed Graph...'));
  print(blue('graph.toString():'));
  print(graph);

  print(blue('\nIs Acylic:'));
  print(graph.isAcyclic);

  print(blue('\nStrongly connected components:'));
  print(graph.stronglyConnectedComponents);

  print(blue('\nShortestPath(d, l):'));
  //print(graph.shortestPath('d', 'l'));

  print(blue('\nInDegree(C):'));
  print(graph.inDegree('c'));

  print(blue('\nOutDegree(C)'));
  print(graph.outDegree('c'));

  print(blue('\nVertices sorted in lexicographical order:'));
  print(graph.vertices);

  print(blue('\nVertices sorted in inverse lexicographical order:'));
  graph.comparator = inverseComparator;
  print(graph.vertices);
  graph.comparator = comparator;

  print(blue('\nInDegreeMap:'));
  print(graph.inDegreeMap);

  print(blue('\nSorted Topological Ordering:'));
  print(graph.sortedTopologicalOrdering);

  print(blue('\nTopological Ordering:'));
  print(graph.topologicalOrdering);

  print(blue('\nLocal Sources:'));
  print(graph.localSources);

  // Add edge to render the graph cyclic
  graph.addEdges('i', {'k'});
  graph.addEdges('l', {'l'});
  graph.addEdges('i', {'d'});

  print(blue('\nCycle:'));
  print(graph.cycle);

  print(blue('\nShortest Paths:'));
  print(graph.shortestPaths('a', target: 'g'));
}
