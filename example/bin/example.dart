import 'package:directed_graph/directed_graph.dart';
import 'package:ansicolor/ansicolor.dart';

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
  var graph = DirectedGraph<String>(
    {
      'a': ['b', 'h', 'c', 'e'],
      'b': ['h'],
      'c': ['h', 'g'],
      'd': ['e', 'f'],
      'e': ['g'],
      'f': ['i'],
      'i': ['l'],
      'k': ['g', 'f']
    },
    comparator: comparator,
  );

  final bluePen = AnsiPen()..blue(bold: true);
  final magentaPen = AnsiPen()..magenta(bold: true);

  print(magentaPen('Example Directed Graph...'));
  print(bluePen('graph.toString():'));
  print(graph);

  print(bluePen('\nIs Acylic:'));
  print(graph.isAcyclic);

  print(bluePen('\nStrongly connected components:'));
  print(graph.stronglyConnectedComponents);

  print(bluePen('\nShortestPath(d, l):'));
  print(graph.shortestPath('d', 'l'));

  print(bluePen('\nInDegree(C):'));
  print(graph.inDegree('c'));

  print(bluePen('\nOutDegree(C)'));
  print(graph.outDegree('c'));

  print(bluePen('\nVertices sorted in lexicographical order:'));
  print(graph.vertices);

  print(bluePen('\nVertices sorted in inverse lexicographical order:'));
  graph.comparator = inverseComparator;
  print(graph.vertices);
  graph.comparator = comparator;

  print(bluePen('\nInDegreeMap:'));
  print(graph.inDegreeMap);

  print(bluePen('\nSorted Topological Ordering:'));
  print(graph.sortedTopologicalOrdering);

  print(bluePen('\nTopological Ordering:'));
  print(graph.topologicalOrdering);

  print(bluePen('\nLocal Sources:'));
  print(graph.localSources);

  // Add edge to render the graph cyclic
  graph.addEdges('i', ['k']);
  graph.addEdges('l', ['l']);
  graph.addEdges('i', ['d']);

  print(bluePen('\nCycle:'));
  print(graph.cycle);

  print(bluePen('\nPaths from D to L.'));
  print(graph.paths('d', 'l'));

  print(bluePen('\nPaths from D to I.'));
  print(graph.paths('d', 'i'));

  print(bluePen('\nPaths from A to H.'));
  print(graph.paths('a', 'h'));

  print(bluePen('\nPaths from L to L.'));
  print(graph.paths('l', 'l'));

  print(bluePen('\nPath from F to F.'));
  print(graph.path('f', 'f'));

  print(bluePen('\nPaths from A to H.'));
  print(graph.shortestPath('a', 'h'));
  //print(graph.shortestPath(d, k));
}
