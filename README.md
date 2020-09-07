
# Directed Graph

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Introduction

An integral part of storing, manipulating, and retrieving numerical data are *data structures* or as they are called in Dart: [collections].
Arguably the most common data structure is the *list*. It enables efficient storage and retrieval of sequential data that can be associated with an index.

A more general (non-linear) data structure where an element may be connected to one, several, or none of the other elements is called a **graph**.

Graphs are useful when keeping track of elements that are linked to or are dependent on other elements.
Examples include: network connections, links in a document pointing to other paragraphs or documents, foreign keys in a relational database, file dependencies in a build system, etc.

The package [`directed_graph`][directed_graph] contains an implementation of a Dart graph that follows the
recommendations found in [graphs-examples] and is compatible with the algorithms provided by [`graphs`][graphs].
It is simple to use and includes methods that enable:
* adding/removing vertices and edges,
* the sorting of vertices.

The library provides access to algorithms
for finding:
* the shortest path between vertices,
* all paths connecting two vertices,
* cycles,
* a topological ordering of the graph vertices.

The class [`GraphCrawler`][GraphCrawler] can be used to find all paths connecting two vertices.

## Terminology

Elements of a graph are called **vertices** (or nodes) and neighbouring vertices are connected by **edges**.
The figure below shows a **directed graph** with unidirectional edges depicted as arrows.
Graph edges are emanating from a vertex and ending at a vertex.

![Directed Graph Image](https://raw.githubusercontent.com/simphotonics/directed_graph/master/images/directed_graph.svg?sanitize=true)

- **In-degree** of a vertex: Number of edges ending at this vertex. For example, vertex H has in-degree 3.
- **Out-degree** of a vertex: Number of edges starting at this vertex. For example, vertex F has out-degree 1.
- **Source**: A vertex with in-degree zero is called (local) source. Vertices A and D in the graph above are local sources.
- **Edge**: An ordered pair of connected vertices. For example, the edge (A, C) starts at vertex A and ends at vertex C.
- **Path**: A directed path is an ordered list of at least two connected vertices. The path (A, E, G) starts at vertex A and ends at vertex G.
- **Cycle**: A path that starts and ends at the same vertex. For example, a self-loop is a cycle. The dashed edges in the figure complete a cycle.
- **DAG**: An acronym for **Directed Acyclic Graph**, a directed graph without cycles.
- **Topological ordering**: An ordered list of all vertices in a graph such that vertex1 occurs before vertex2 if there is an edge pointing from vertex1 to vertex2.
A topological ordering of the graph above is: [A, D, B, C, E, K, F, G, H, I, L]. Hereby, dashed edges were disregarded since a cyclic graph does
not have a topological ordering.

**Note**: In the context of this package the definition of *edge* might be more lax compared to a rigorous mathematical definition.
For example, self-loops, that is edges connecting a vertex to itself are explicitly allowed.

For simplicity, edges are (internally) stored in a structure of type `Map<Vertex<T>, List<Vertex<T>>>` and there is nothing preventing a user from
inserting self-loops or multiple edges between the same nodes. While self-loops will render a graph cyclic, multiple entries of the same edge
do not affect the algorithms calculating a topological ordering of vertices.

## Usage

To use this library include [`directed_graph`][directed_graph] as a dependency in your pubspec.yaml file. The
example below shows how to construct a graph. The constructor takes an optional comparator function
as parameter. If a comparator is specified, vertices are sorted accordingly. For more information see [comparator].

```Dart
import 'package:directed_graph/directed_graph.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:directed_graph/graph_crawler.dart';

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

  // Constructing a graph from vertices.
  var graph = DirectedGraph<String>(
    {
      a: [b, h, c, e],
      b: [h],
      c: [h, g],
      d: [e, f],
      e: [g],
      f: [i],
      i: [l],
      k: [g, f]
    },
    comparator: comparator,
  );

  // Constructing a graph from data.
  // Note: Each object is converted to a vertex.
  var graphII = DirectedGraph<String>.fromData({
    'A': ['B', 'H', 'C', 'E'],
    'B': ['H'],
    'C': ['H', 'G'],
    'D': ['E', 'F'],
    'E': ['G'],
    'F': ['I'],
    'I': ['L'],
    'K': ['G', 'F'],
  }, comparator: comparator);

  final bluePen = AnsiPen()..blue(bold: true);
  final magentaPen = AnsiPen()..magenta(bold: true);

  print(magentaPen('Example Directed Graph...'));
  print(bluePen('\ngraph.toString():'));
  print(graph);

  print(bluePen('\ngraphII.toString():'));
  print(graphII);

  print(bluePen('\nIs Acylic:'));
  print(graph.isAcyclic);

  print(bluePen('\nStrongly connected components:'));
  print(graph.stronglyConnectedComponents);

  print(bluePen('\nShortestPath(d, l):'));
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
  print(graph.sortedTopologicalOrdering);

  print(bluePen('\nTopological Ordering:'));
  print(graph.topologicalOrdering);

  print(bluePen('\nLocal Sources:'));
  print(graph.localSources);

  // Add edge to render the graph cyclic
  graph.addEdges(i, [k]);
  graph.addEdges(l, [l]);

  print(bluePen('\nCycle:'));
  print(graph.cycle);

  // Create graph crawler.
  final crawler = GraphCrawler<String>(edges: graph.edges);

  print(bluePen('\nPaths from D to L.'));
  print(crawler.paths(d, l));

  print(bluePen('\nPaths from D to I.'));
  print(crawler.paths(d, i));

  print(bluePen('\nPaths from A to H.'));
  print(crawler.paths(a, h));

  print(bluePen('\nPaths from L to L.'));
  print(crawler.paths(l, l));

  print(bluePen('\nPath from F to F.'));
  print(crawler.path(f, f));

  print(bluePen('\nPath from A to H.'));
  print(crawler.path(a, h));

  print(bluePen('\nTree with root L.'));
  print(crawler.tree(l));

  print(bluePen('\nTree with root A, target H.'));
  print(crawler.tree(a, target: h));

  print(bluePen('\nTree with root A, target G.'));
  print(crawler.tree(a, target: g));

  print(bluePen('\nPaths from L to L.'));
  print(crawler.paths(l, l));
}

```

<details> <summary> Click to show the console output. </summary>

  ```Console
  $ dart example/bin/example.dart
  Example Directed Graph...

  graph.toString():
  {
   A: [B, H, C, E],
   B: [H],
   C: [H, G],
   D: [E, F],
   E: [G],
   F: [I],
   G: [],
   H: [],
   I: [L],
   K: [G, F],
   L: [],
  }

  Example Directed Graph...

  graphII.toString():
  {
   A: [B, H, C, E],
   B: [H],
   C: [H, G],
   D: [E, F],
   E: [G],
   F: [I],
   G: [],
   H: [],
   I: [L],
   K: [G, F],
   L: [],
  }

  Is Acylic:
  true

  Strongly connected components:
  [[H], [B], [G], [C], [E], [A], [L], [I], [F], [D], [K]]

  ShortestPath(d, l):
  [F, I, L]

  InDegree(C):
  1

  OutDegree(C)
  2

  Vertices sorted in lexicographical order:
  [A, B, C, D, E, F, G, H, I, K, L]

  Vertices sorted in inverse lexicographical order:
  [L, K, I, H, G, F, E, D, C, B, A]

  InDegreeMap:
  {A: 0, B: 1, H: 3, C: 1, E: 2, G: 3, D: 0, F: 2, I: 1, L: 1, K: 0}

  Sorted Topological Ordering:
  [A, B, C, D, E, H, K, F, G, I, L]

  Topological Ordering:
  [A, B, C, D, E, H, K, F, I, G, L]

  Local Sources:
  [[A, D, K], [B, C, E, F], [G, H, I], [L]]

  Cycle:
  [L, L]

  Paths from D to L.
  [[D, F, I, L]]

  Paths from D to I.
  [[D, F, I]]

  Paths from A to H.
  [[A, B, H], [A, H], [A, C, H]]

  Paths from L to L.
  [[L, L]]

  Path from F to F.
  [F, I, K, F]

  Path from A to H.
  [A, H]

  Tree with root L.
  [[L], [L, L]]
  
  Tree with root A, target H.
  [[A], [A, B], [A, H]]
  
  Tree with root A, target G.
  [[A], [A, B], [A, H], [A, C], [A, E], [A, B, H], [A, C, H], [A, C, G]]
  
  Paths from L to L.
  [[L, L]]

  ```

</details>


## Examples

For further information on how to generate a topological sorting of vertices see [example].

## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[comparator]: https://api.flutter.dev/flutter/dart-core/Comparator.html
[issue tracker]: https://github.com/simphotonics/directed_graph/issues

[collections]: https://api.dart.dev/stable/2.8.4/dart-collection/dart-collection-library.html
[example]: https://github.com/simphotonics/directed_graph/tree/master/example
[graphs-examples]: https://pub.dev/packages/graphs#-example-tab-
[graphs]: https://pub.dev/packages/graphs
[directed_graph]: https://pub.dev/packages/directed_graph
[GraphCrawler]: https://pub.dev/documentation/directed_graph/latest/directed_graph/GraphCrawler-class.html
