import 'package:directed_graph/src/base/directed_graph_base.dart';
import 'package:directed_graph/src/base/graph_crawler_base.dart';

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

  // final bluePen = AnsiPen()..blue(bold: true);
  // final magentaPen = AnsiPen()..magenta(bold: true);

  // print(magentaPen('Example Directed Graph...'));
  // print(bluePen('graph.toString():'));
  // print(graph);

  // print(bluePen('\nIs Acylic:'));
  // print(graph.isAcyclic);

  // print(bluePen('\nStrongly connected components:'));
  // //print(graph.stronglyConnectedComponents);

  // print(bluePen('\nShortestPath(d, l):'));
  // //print(graph.shortestPath('d', 'l'));

  // print(bluePen('\nInDegree(C):'));
  // print(graph.inDegree('c'));

  // print(bluePen('\nOutDegree(C)'));
  // print(graph.outDegree('c'));

  // print(bluePen('\nVertices sorted in lexicographical order:'));
  // print(graph.vertices);

  // print(bluePen('\nVertices sorted in inverse lexicographical order:'));
  // graph.comparator = inverseComparator;
  // print(graph.vertices);
  // graph.comparator = comparator;

  // print(bluePen('\nInDegreeMap:'));
  // print(graph.inDegreeMap);

  // print(bluePen('\nSorted Topological Ordering:'));
  // print(graph.sortedTopologicalOrdering);

  // print(bluePen('\nTopological Ordering:'));
  // print(graph.topologicalOrdering);

  // print(bluePen('\nLocal Sources:'));
  // print(graph.localSources);

  // // Add edge to render the graph cyclic
  // graph.addEdges('i', {'k'});
  // graph.addEdges('l', {'l'});
  // graph.addEdges('i', {'d'});

  // print(bluePen('\nCycle:'));
  // print(graph.cycle);

  // final crawler = GraphCrawler(graph.edges);

  // print(bluePen('\nPaths from D to L.'));
  // print(crawler.paths('d', 'l'));

  // print(bluePen('\nPaths from D to I.'));
  // print(crawler.paths('d', 'i'));

  // print(bluePen('\nPaths from A to H.'));
  // print(crawler.paths('a', 'h'));

  // print(bluePen('\nPaths from L to L.'));
  // print(crawler.paths('l', 'l'));

  // print(bluePen('\nPath from F to F.'));
  // print(crawler.path('f', 'f'));

  // print(bluePen('\nPaths from A to H.'));

  print('Example Directed Graph...');
  print('graph.toString():');
  print(graph);

  print('\nIs Acylic:');
  print(graph.isAcyclic);

  //print('\nStrongly connected components:');
  //print(graph.stronglyConnectedComponents);

  //print('\nShortestPath(d, l):');
  //print(graph.shortestPath('d', 'l');

  print('\nInDegree(C):');
  print(graph.inDegree('c'));

  print('\nOutDegree(C)');
  print(graph.outDegree('c'));

  print('\nVertices sorted in lexicographical order:');
  print(graph.vertices);

  print('\nVertices sorted in inverse lexicographical order:');
  graph.comparator = inverseComparator;
  print(graph.vertices);
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
  //graph.addEdges('i', {'d'});

  print('\nCycle:');
  print(graph.cycle);

  final crawler = GraphCrawler(graph.edges);

  print('\nPaths from D to L.');
  print(crawler.paths('d', 'l'));

  print('\nPaths from D to I.');
  print(crawler.paths('d', 'i'));

  print('\nPaths from A to H.');
  print(crawler.paths('a', 'h'));

  print('\nPaths from L to L.');
  print(crawler.paths('l', 'l'));

  print('\nPath from F to F.');
  print(crawler.path('f', 'f'));

  print('\nSimple Tree: Root D');
  print(crawler.simpleTree('d', target: 'i'));

  print('\nTree: Root D');
  print(crawler.tree('d', target: 'k', maxCount: 2));

  print('\nWalks: Root D');
  print(crawler.walks('d','g',maxCount: 2));



}
