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
  var red = Vertex<String>('red');
  var yellow = Vertex<String>('yellow');
  var orange = Vertex<String>('orange');
  var green = Vertex<String>('green');
  var blue = Vertex<String>('blue');
  var violet = Vertex<String>('violet');
  var gray = Vertex<String>('gray');
  var darkRed = Vertex<String>('darkRed');

  int comparator(
    Vertex<String> vertex1,
    Vertex<String> vertex2,
  ) {
    return vertex1.data.compareTo(vertex2.data);
  }

  var graph = DirectedGraph<String>(
    {
      orange: [red, yellow],
      green: [yellow, blue],
      violet: [red, blue],
      gray: [red, yellow, blue],
      red: [darkRed],
    },
    comparator: comparator,
  );

  AnsiPen bluePen = AnsiPen()..blue(bold: true);
  AnsiPen magentaPen = AnsiPen()..magenta(bold: true);

  print(magentaPen('Example Directed Graph...'));
  print(bluePen('\nPrimary colour graph:'));
  print(graph);

  print(bluePen('\nIs Acylic:'));
  print(graph.isAcyclic());

  print(bluePen('\nStrongly connected components:'));
  print(graph.stronglyConnectedComponents());

  print(bluePen('\nShortestPath(orange,red):'));
  print(graph.shortestPath(orange, darkRed));

  print(bluePen('\nInDegree(red):'));
  print(graph.inDegree(red));

  print(bluePen('\nVertices sorted in lexicographical order:'));
  print(graph.vertices);

  print(bluePen('\nInDegreeMap:'));
  print(graph.inDegreeMap);

  print(bluePen('\nTopologicalOrdering:'));
  print(graph.topologicalOrdering(comparator));

  print(bluePen('\nTopologicalOrderingDFS:'));
  print(graph.topologicalOrderingDFS());
}
