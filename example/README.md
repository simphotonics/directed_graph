# Directed Graph


## Example
The example located in this folder demonstrates how to create
a [directed_graph], manipulate its vertices, determine if the graph is acyclic, or
obtain a list of vertices in topological order.

The program can be run in a terminal by navigating to the
folder *directed_graph/example* in your local copy of this library and using the command:
```Shell
$ dart bin/example.dart
```

```Dart
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

  // Function used to sort vertices in lexicographical order.
  int comparator(
    Vertex<String> vertex1,
    Vertex<String> vertex2,
  ) {
    return vertex1.data.compareTo(vertex2.data);
  }

  // Instantiate a directed graph:
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
  print(graph.topologicalOrderingDFS(comparator));
}
```


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs
[directed_graph]: https://github.com/simphotonics/directed_graph/