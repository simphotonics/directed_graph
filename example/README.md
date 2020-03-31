# Directed Graph
[![Build Status](https://travis-ci.com/simphotonics/quote_buffer.svg?branch=master)](https://travis-ci.com/simphotonics/quote_buffer)


## Example
The example located in this folder demonstrates how to create
a [directed_graph], manipulate its vertices, determine if the graph is acyclic, or
obtain a list of vertices in topological order.

The program can be run in a terminal by navigating to the
folder *directed_graph* in your local copy of this library and using the command:
```Shell
$ dart example/bin/example.dart
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
  var aa = Vertex<String>('aa');
  var ab = Vertex<String>('ab');
  var b4 = Vertex<String>('b4');
  var d5 = Vertex<String>('d5');
  var e9 = Vertex<String>('e9');
  var e8 = Vertex<String>('e8');
  var ff = Vertex<String>('ff');
  var gg = Vertex<String>('gg');

  // A comparator function can be used to sort vertices.
  // See functions: topologicalOrdering() and
  //                topologicalOrderingDFS() below.
  int comparator(Vertex<String> v1, Vertex<String> v2) {
    return v1.data.compareTo(v2.data);
  }

  // Instantiate a graph.
  var graph = DirectedGraph<String>(
    {
      e8: [ff, e9, gg],
      aa: [ab, e8],
      b4: [d5, e8],
    },
  );

  AnsiPen bluePen = AnsiPen()..blue(bold: true);
  AnsiPen magentaPen = AnsiPen()..magenta(bold: true);

  print(magentaPen('Example Directed Graph...'));
  print(bluePen('\nPrimary colour graph:'));
  print(graph);

  print(bluePen('\nStrongly connected components:'));
  print(graph.stronglyConnectedComponents());

  print(bluePen('\nShortestPath(orange,red):'));
  print(graph.shortestPath(aa, gg));

  print(bluePen('\nInDegree(red):'));
  print(graph.inDegree(e9));

  print(bluePen('\nVertices'));
  print(graph.vertices);

  print(bluePen('\nInDegreeMap'));
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