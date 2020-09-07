import 'package:ansicolor/ansicolor.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:directed_graph/graph_crawler.dart';

// To run this program navigate to
// the folder 'directed_graph/example'
// in your terminal and type:
//
// # dart bin/example_crawler.dart
//
// followed by enter.

// The graph is shown in graph.png.
void main() {
  final bluePen = AnsiPen()..blue(bold: true);
  final magentaPen = AnsiPen()..magenta(bold: true);
  final graph = DirectedGraph<String>.fromData({
    'A': ['B', 'C', 'D'],
    'B': ['A', 'C'],
    'C': ['A', 'B'],
    'D': ['A', 'B'],
    'E': ['F'],
    'F': [],
    'G': ['H'],
    'H': [],
    'I': ['J'],
    'J': [],
    'K': ['L'],
    'L': [],
    'M': ['D'],
  });

  print(graph);

  // Create graph crawler.
  final crawler = GraphCrawler<String>(edges: graph.edges);

  print(magentaPen('Example Directed Graph...'));
  print(bluePen('graph.toString():'));
  print(graph);

  print(bluePen('\nPaths from D to C.'));
  print(crawler.paths(graph.vertices[3], graph.vertices[2]));

  //print(bluePen('\nPaths from D to C. Old method.'));
  //print(crawler.pathsOld(graph.vertices[3], graph.vertices[2]));


  print(bluePen('\nPaths from D to C, maxWalkCount: 2'));
  print(crawler.paths(graph.vertices[3], graph.vertices[2], maxWalkCount: 2));

  print(bluePen('\nPaths from D to C, maxWalkCount: 3'));
  print(crawler.paths(graph.vertices[3], graph.vertices[2], maxWalkCount: 3));

  print(bluePen('\nPath from D to C.'));
  print(crawler.path(graph.vertices[3], graph.vertices[2]));

  print(bluePen('\nTree with root D, maxWalkCount: 1.'));
  print(crawler.tree(graph.vertices[3]));

  print(bluePen('\nTree with root D, maxWalkCount: 2.'));
  print(crawler.tree(graph.vertices[3], maxWalkCount: 2));

  print(bluePen('\ngraph.findCycle().'));
  print(graph.findCycle());
}
