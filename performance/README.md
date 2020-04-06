# Directed Graph

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Test Graph
To set up the benchmark, the following directed graph is initialized:
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
`graph.topologicalOrderingDFS()`,
`graph.topologicalOrdering(comparator)`,
`graph.stronglyConnectedComponents()`,
`graph.localSource()`,
`graph.remove(h)` followed by
```graph.addEdges(a, [h]), graph.addEdges(b, [h]) , graph.addEdges(c, [h])```.

Each test is run 10 times in a loop for a minimum duration of 2000 milliseconds.
This is the default setting provided by the package [benchmark_harness].

To run the benchmark program, navigate to the folder *directed_graph* in your downloaded
copy of this library and use
the following command:
```console
# dart performance/bin/benchmark.dart
```

A typical shell output for a benchmark run on a machine with a Intel Core Dual i5-6260U CPU @ 1.80GHz is listed below:
```console
Topological Ordering DFS ...
[A, B, C, D, E, H, K, F, I, G, L]
Topological Ordering DFS:(RunTime): 28.846092826030517 us.

Topological Ordering Kahn ...
[A, B, C, D, E, H, K, F, G, I, L]
Topological Ordering Kahn(RunTime): 31.065672569120846 us.

Strongly Connected Components Tarjan ...
[[H], [B], [G], [C], [E], [A], [L], [I], [F], [D], [K]]
Strongly Connected Componets Tarjan:(RunTime): 34.84978219201952 us.

Local Sources ...
[[A, D, K], [B, C, E, F], [G, H, I], [L]]
Local Sources:(RunTime): 41.22659905592315 us.

Test Graph ...
{
 A: [B, C, E, H],
 B: [H],
 C: [G, H],
 D: [E, F],
 E: [],
 F: [I],
 G: [],
 H: [],
 I: [L],
 K: [G, F],
 L: [],
}
Removing/Adding Vertices(RunTime): 12.399947920218736 us.

```
The method `topologicalOrderingDFS()`, based on a depth-first search algorithm, executes marginaly faster
but `topologicalOrdering()`, based on Kahn's algorithm, takes an optional comparator function as argument
and is able to generate a sorted topological ordering. In the example above the vertices are sorted in
topological and lexicographical order.

The method `stronglyConnectedComponents()` is provided for convenience
only as it is simply calling the homonymously named function provided by the package [graphs].


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[benchmark_harness]: https://pub.dev/packages/benchmark_harness
[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs