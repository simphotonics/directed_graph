
# Directed Graph - Benchmark

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Setup
To set up the benchmark, a numerical representation of the following directed graph is initialized:

![Directed Graph Image](https://raw.githubusercontent.com/simphotonics/directed_graph/master/images/directed_graph.svg?sanitize=true)

```Dart
import 'package:directed_graph/directed_graph.dart';

// Function used to compare two vertices.
int comparator(
  Vertex<String> vertex1,
  Vertex<String> vertex2,
) {
  return vertex1.data.compareTo(vertex2.data);
}

// Directed graph
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
```
## Benchmark
The benchmark compares the average execution time of the functions:
- `graph.inDegreeMap`,
- `graph.topologicalOrdering`,
- `graph.sortedTopologicalOrdering`,
- `graph.stronglyConnectedComponents`,
- `graph.localSources`,
- `graph.remove(h)` followed by
   ```graph.addEdges(a, [h]), graph.addEdges(b, [h]) , graph.addEdges(c, [h])```.
- `crawler.paths()`
- `graph.cycle`
- `graph.findCycle()`

Each test is run 10 times in a loop for a minimum duration of 2000 milliseconds.
This is the default setting provided by the package [benchmark_harness].

To run the benchmark program, navigate to the folder *directed_graph* in your downloaded copy of this library and use
the following command:
```console
  # dart benchmark/bin/benchmark.dart
```
A typical shell output for a benchmark run on a machine with an Intel Core Dual i5-6260U CPU @ 1.80GHz is listed below:
```console
 InDegreeMap:
 {A: 0, B: 1, H: 3, C: 1, E: 2, G: 3, D: 0, F: 2, I: 1, L: 1, K: 0}
 InDegreeMap:(RunTime): 0.13063595345728377 us.

 Topological Ordering DFS ...
 [A, B, C, D, E, H, K, F, I, G, L]
 Topological Ordering DFS:(RunTime): 10.536389929353753 us.

 Topological Ordering Kahn ...
 [A, B, C, D, E, H, K, F, G, I, L]
 Topological Ordering Kahn(RunTime): 30.617240481912955 us.

 Strongly Connected Components Tarjan ...
 [[H], [B], [G], [C], [E], [A], [L], [I], [F], [D], [K]]
 Strongly Connected Componets Tarjan:(RunTime): 37.64948608862618 us.

 Local Sources ...
 [[A, D, K], [B, C, E, F], [G, H, I], [L]]
 Local Sources:(RunTime): 41.25202648350968 us.

 Test Graph ...
 {
  A: [B, C, E, H],
  B: [H],
  C: [G, H],
  D: [E, F],
  E: [G],
  F: [I],
  G: [],
  H: [],
  I: [L],
  K: [G, F],
  L: [],
 }
 Removing/Adding Vertices(RunTime): 13.247191606612972 us.

 Shortest Path (graphs) ...
 [F, I, L]
 ShortestPath(RunTime): 8.866357526643379 us.

 Crawler.paths(D, L) ...
 [[D, F, I, L]]
 CrawlerTest(RunTime): 7.973674977873107 us.

 graph.cycle ...
 [F, I, K, F]
 GraphCycle(RunTime): 14.154252269976858 us.

 graph.findCycle() ...
 [F, I, K, F]
 GraphFindCycle(RunTime): 20.847191386013737 us.
```
The method `topologicalOrdering`(based on a depth-first search algorithm)
executes significantly faster than `sortedTopologicalOrdering`(based on Kahn's algorithm).
In the example above, see "Topological Ordering Kahn", the vertices are sorted in
topological and lexicographical order.

The method `stronglyConnectedComponents()` is provided for convenience
only as it is simply calling the homonymously named function provided by the package [graphs].


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[benchmark_harness]: https://pub.dev/packages/benchmark_harness
[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs