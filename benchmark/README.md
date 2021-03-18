
# Directed Graph - Benchmark

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Running the benchmarks

To run the benchmarks, navigate to the package root in your local copy of [`directed_graph`][directed_graph] and
use the command:
```Console
$ pub run benchmark
```
A sample benchmark output is listed below:
```Dart
 DONE  ./benchmark/bin/weighted_directed_graph_benchmark.dart (3 s)
 Manipulating edges:
  ✓ remove vertex l (8 us)
  ✓ sort edges (30 us)
  ✓ sort edges by weight (31 us)
 Topology:
  ✓ isAcyclic (20 us)
  ✓ topologicalOrdering (29 us)
  ✓ sortedTopologicalOrdering (42 us)
  ✓ transitiveClosure (459 us)
  ✓ cycleVertex (20 us)
  ✓ cycle (20 us)
  ✓ localSources (42 us)
  ✓ stronglyConnectedComponents (41 us)
  ✓ shortestPaths (10 us)
 Selecting path by weight:
  ✓ lightest path a -> g (27 us)
  ✓ heaviest path a -> g (25 us)

 DONE  ./benchmark/bin/graph_crawler_benchmark.dart (1 s)
 Topology:
  ✓ walks (39 us)
  ✓ path (14 us)
  ✓ paths (13 us)
  ✓ tree (33 us)
  ✓ simpleTree (11 us)
  ✓ mappedTree (23 us)

 DONE  ./benchmark/bin/directed_graph_benchmark.dart (2 s)
 Manipulating edges:
  ✓ remove vertex l (6 us)
  ✓ sort edges (14 us)
 Topology:
  ✓ isAcyclic (16 us)
  ✓ topologicalOrdering (25 us)
  ✓ sortedTopologicalOrdering (38 us)
  ✓ transitiveClosure (51 us)
  ✓ cycleVertex (16 us)
  ✓ cycle (16 us)
  ✓ localSources (39 us)
  ✓ stronglyConnectedComponents (37 us)
  ✓ shortestPaths (8 us)

Benchmark suites: 3 passed, 3 total
Benchmarks:       31 passed, 31 total
Time:             8 s
Ran all benchmark suites.
```

The report above was generated on a PC with an Intel Core i5-6260U processor and 32GB of memory
using the package [`benchmark`][benchmark].




## Features and bugs
Please file feature requests and bugs at the [issue tracker].


[benchmark]: https://pub.dev/packages/benchmark

[issue tracker]: https://github.com/simphotonics/directed_graph/issues

[directed_graph]: https://pub.dev/packages/directed_graph