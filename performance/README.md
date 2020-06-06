# Directed Graph

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Test Graph
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
  # dart performance/bin/benchmark.dart
```
A typical shell output for a benchmark run on a machine with an Intel Core Dual i5-6260U CPU @ 1.80GHz is listed below:
```console
  Topological Ordering DFS ...
  [A, B, C, D, E, H, K, F, I, G, L]
  Topological Ordering DFS:(RunTime): 10.785123031044915 us.

  Topological Ordering Kahn ...
  [A, B, C, D, E, H, K, F, G, I, L]
  Topological Ordering Kahn(RunTime): 31.678123416117586 us.

  Strongly Connected Components Tarjan ...
  [[H], [B], [G], [C], [E], [A], [L], [I], [F], [D], [K]]
  Strongly Connected Componets Tarjan:(RunTime): 37.47844989131249 us.

  Local Sources ...
  [[A, D, K], [B, C, E, F], [G, H, I], [L]]
  Local Sources:(RunTime): 41.797513061650996 us.

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
  Removing/Adding Vertices(RunTime): 13.83467644312247 us.

  Shortest Path (graphs) ...
  [F, I, L]
  ShortestPath(RunTime): 10.235791456193414 us.

  Crawler.paths(D, L) ...
  [[D, F, I, L]]
  CrawlerTest(RunTime): 8.46654869953942 us.

  graph.cycle ...
  [F, I, K, F]
  GraphCycle(RunTime): 15.832469146552885 us.

  graph.findCycle() ...
  [F, I, K, F]
  GraphFindCycle(RunTime): 23.307411723575342 us
```
The method `topologicalOrdering()`, based on a depth-first search algorithm, executes marginaly faster
but `sortedTopologicalOrdering()`, based on Kahn's algorithm is able to generate
a sorted topological ordering. In the example above the vertices are sorted in
topological and lexicographical order.

The method `stronglyConnectedComponents()` is provided for convenience
only as it is simply calling the homonymously named function provided by the package [graphs].


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[benchmark_harness]: https://pub.dev/packages/benchmark_harness
[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs