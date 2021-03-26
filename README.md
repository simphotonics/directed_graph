
# Directed Graph

[![Dart](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml)

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
* the path with the lowest/highest weight (for weighted directed graphs),
* all paths connecting two vertices,
* cycles,
* a topological ordering of the graph vertices.

The class [`GraphCrawler`][GraphCrawler] can be used to retrieve *paths* or *walks* connecting two vertices.

## Terminology

Elements of a graph are called **vertices** (or nodes) and neighbouring vertices are connected by **edges**.
The figure below shows a **directed graph** with unidirectional edges depicted as arrows.
Graph edges are emanating from a vertex and ending at a vertex. In a **weighted directed graph** each
edge is assigned a weight.

![Directed Graph Image](https://github.com/simphotonics/directed_graph/raw/main/images/directed_graph.svg?sanitize=true)

- **In-degree** of a vertex: Number of edges ending at this vertex. For example, vertex H has in-degree 3.
- **Out-degree** of a vertex: Number of edges starting at this vertex. For example, vertex F has out-degree 1.
- **Source**: A vertex with in-degree zero is called (local) source. Vertices A and D in the graph above are local sources.
- **Directed Edge**: An ordered pair of connected vertices (v<sub>i</sub>, v<sub>j</sub>). For example, the edge (A, C) starts at vertex A and ends at vertex C.
- **Path**: A path \[v<sub>i</sub>, ...,   v<sub>n</sub>\] is an ordered list of at least two connected vertices where each **inner** vertex is **distinct**.
   The path \[A, E, G\] starts at vertex A and ends at vertex G.
- **Cycle**: A cycle is an ordered *list* of connected vertices where each inner vertex is distinct and the
first and last vertices are identical. The sequence \[F, I, K, F\] completes a cycle.
- **Walk**: A walk is an ordered *list* of at least two connected vertices.
\[D, F, I, K, F\] is a walk but not a path since the vertex F is listed twice.
- **DAG**: An acronym for **Directed Acyclic Graph**, a directed graph without cycles.
- **Topological ordering**: An ordered *set* of all vertices in a graph such that v<sub>i</sub>
occurs before v<sub>j</sub> if there is a directed edge (v<sub>i</sub>, v<sub>j</sub>).
A topological ordering of the graph above is: \{A, D, B, C, E, K, F, G, H, I, L\}.
Hereby, dashed edges were disregarded since a cyclic graph does not have a topological ordering.

**Note**: In the context of this package the definition of *edge* might be more lax compared to a
rigorous mathematical definition.
For example, self-loops, that is edges connecting a vertex to itself are explicitly allowed.

## Usage

To use this library include [`directed_graph`][directed_graph] as a dependency in your pubspec.yaml file. The
example below shows how to construct an object of type [`DirectedGraph`][DirectedGraph].
The constructor takes an optional comparator function
as parameter. If a comparator is specified, vertices are sorted accordingly. For more information see [comparator].

```Dart
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

```

<details> <summary> Click to show the console output. </summary>

```Console
$ dart example/bin/directed_graph_example.dart
Example Directed Graph...
graph.toString():
{
 'a': {'b', 'h', 'c', 'e'},
 'b': {'h'},
 'c': {'h', 'g'},
 'd': {'e', 'f'},
 'e': {'g'},
 'f': {'i'},
 'g': {},
 'h': {},
 'i': {'l'},
 'k': {'g', 'f'},
 'l': {},
}

Is Acylic:
true

Strongly connected components:
[[h], [b], [g], [c], [e], [a], [l], [i], [f], [d], [k]]

ShortestPath(d, l):

InDegree(C):
1

OutDegree(C)
2

Vertices sorted in lexicographical order:
[a, b, c, d, e, f, g, h, i, k, l]

Vertices sorted in inverse lexicographical order:
[l, k, i, h, g, f, e, d, c, b, a]

InDegreeMap:
{a: 0, b: 1, h: 3, c: 1, e: 2, g: 3, d: 0, f: 2, i: 1, l: 1, k: 0}

Sorted Topological Ordering:
{a, b, c, d, e, h, k, f, g, i, l}

Topological Ordering:
{a, b, c, d, e, h, k, f, i, g, l}

Local Sources:
[[a, d, k], [b, c, e, f], [g, h, i], [l]]

Cycle:
[l, l]

Shortest Paths:
{e: (e), c: (c), h: (h), a: (), g: (c, g), b: (b)}

```
</details>

## Weighted Directed Graphs

The example below shows how to construct an object of type [`WeightedDirectedGraph`][WeightedDirectedGraph].
Initial graph edges are specified in the form of map of type `Map<T, Map<T, W>>`. The vertex type `T` extends
`Object` and therefore must be a non-nullable. The type associated with the edge weight `W` extends `Comparable`
to enable sorting of vertices by their edge weight.

The constructor takes an optional comparator function
as parameter. If a comparator is specified, vertices are sorted accordingly.
For more information see [comparator].

```Dart

import 'package:directed_graph/directed_graph.dart';

void main(List<String> args) {
  int comparator(
    String s1,
    String s2,
  ) {
    return s1.compareTo(s2);
  }

  final a = 'a';
  final b = 'b';
  final c = 'c';
  final d = 'd';
  final e = 'e';
  final f = 'f';
  final g = 'g';
  final h = 'h';
  final i = 'i';
  final k = 'k';
  final l = 'l';

  int sum(int left, int right) => left + right;

  var graph = WeightedDirectedGraph<String, int>(
    {
      a: {b: 1, h: 7, c: 2, e: 40, g:7},
      b: {h: 6},
      c: {h: 5, g: 4},
      d: {e: 1, f: 2},
      e: {g: 2},
      f: {i: 3},
      i: {l: 3, k: 2},
      k: {g: 4, f: 5},
      l: {l: 0}
    },
    summation: sum,
    zero: 0,
    comparator: comparator,
  );

  print('Weighted Graph:');
  print(graph);

  print('\nNeighbouring vertices sorted by weight:');
  print(graph..sortEdgesByWeight());

  final lightestPath = graph.lightestPath(a, g);
  print('\nLightest path a -> g');
  print('$lightestPath weight: ${graph.weightAlong(lightestPath)}');

  final heaviestPath = graph.heaviestPath(a, g);
  print('\nHeaviest path a -> g');
  print('$heaviestPath weigth: ${graph.weightAlong(heaviestPath)}');

  final shortestPath = graph.shortestPath(a, g);
  print('\nShortest path a -> g');
  print('$shortestPath weight: ${graph.weightAlong(shortestPath)}');
}
```

<details> <summary> Click to show the console output. </summary>

```Console
$ dart example/bin/weighted_graph_example.dart
Weighted Graph:
{
 'a': {'b': 1, 'h': 7, 'c': 2, 'e': 40, 'g': 7},
 'b': {'h': 6},
 'c': {'h': 5, 'g': 4},
 'd': {'e': 1, 'f': 2},
 'e': {'g': 2},
 'f': {'i': 3},
 'g': {},
 'h': {},
 'i': {'l': 3, 'k': 2},
 'k': {'g': 4, 'f': 5},
 'l': {'l': 0},
}

Neighbouring vertices sorted by weight
{
 'a': {'b': 1, 'c': 2, 'h': 7, 'g': 7, 'e': 40},
 'b': {'h': 6},
 'c': {'g': 4, 'h': 5},
 'd': {'e': 1, 'f': 2},
 'e': {'g': 2},
 'f': {'i': 3},
 'g': {},
 'h': {},
 'i': {'k': 2, 'l': 3},
 'k': {'g': 4, 'f': 5},
 'l': {'l': 0},
}

Lightest path a -> g
[a, c, g] weight: 6

Heaviest path a -> g
[a, e, g] weigth: 42

Shortest path a -> g
[a, g] weight: 7
```
</details>

## Examples

For further information on how to generate a topological sorting of vertices see [example].

## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[comparator]: https://api.dart.dev/stable/dart-core/Comparator.html

[issue tracker]: https://github.com/simphotonics/directed_graph/issues

[collections]: https://api.dart.dev/stable/dart-collection/dart-collection-library.html

[example]: https://github.com/simphotonics/directed_graph/tree/master/example

[graphs-examples]: https://pub.dev/packages/graphs#-example-tab-

[graphs]: https://pub.dev/packages/graphs

[directed_graph]: https://pub.dev/packages/directed_graph

[GraphCrawler]: https://pub.dev/documentation/directed_graph/latest/directed_graph/GraphCrawler-class.html

[DirectedGraph]: https://pub.dev/documentation/directed_graph/latest/directed_graph/DirectedGraph-class.html

[WeightedDirectedGraph]: https://pub.dev/documentation/directed_graph/latest/directed_graph/WeightedDirectedGraph-class.html
