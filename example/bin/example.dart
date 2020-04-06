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
  var a = Vertex<String>('A');
  var b = Vertex<String>('B');
  var c = Vertex<String>('C');
  var d = Vertex<String>('D');
  var e = Vertex<String>('E');
  var f = Vertex<String>('F');
  var g = Vertex<String>('G');
  var h = Vertex<String>('H');
  var i = Vertex<String>('I');
  var k = Vertex<String>('K');
  var l = Vertex<String>('L');

  int comparator(
    Vertex<String> vertex1,
    Vertex<String> vertex2,
  ) {
    return vertex1.data.compareTo(vertex2.data);
  }

  int inverseComparator(Vertex<String> vertex1, Vertex<String> vertex2) =>
      -comparator(vertex1, vertex2);

  var graph = DirectedGraph<String>(
    {
      a: [b, h, c, e],
      d: [e, f],
      b: [h],
      c: [h, g],
      f: [i],
      i: [l],
      k: [g, f]
    },
    comparator: comparator,
  );

  AnsiPen bluePen = AnsiPen()..blue(bold: true);
  AnsiPen magentaPen = AnsiPen()..magenta(bold: true);

  print(magentaPen('Example Directed Graph...'));
  print(bluePen('\ngraph.toString():'));
  print(graph);

  print(bluePen('\nIs Acylic:'));
  print(graph.isAcyclic());

  print(bluePen('\nStrongly connected components:'));
  print(graph.stronglyConnectedComponents());

  print(bluePen('\nShortestPath(orange,darkRed):'));
  print(graph.shortestPath(d, l));

  print(bluePen('\nInDegree(C):'));
  print(graph.inDegree(c));

  print(bluePen('\nOutDegree(C)'));
  print(graph.outDegree(c));

  print(bluePen('\nVertices sorted in lexicographical order:'));
  print(graph.vertices);

  print(bluePen('\nVertices sorted in inverse lexicographical order:'));
  graph.comparator = inverseComparator;
  print(graph.vertices);
  graph.comparator = comparator;

  print(bluePen('\nInDegreeMap:'));
  print(graph.inDegreeMap);

  print(bluePen('\nSorted Topological Ordering:'));
  print(graph.sortedTopologicalOrdering());

  print(bluePen('\nTopological Ordering:'));
  print(graph.topologicalOrdering());

  print(bluePen('\nLocal Sources:'));
  print(graph.localSources());

  print('${a.hashCode}');
}
