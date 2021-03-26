
# Directed Graph - Benchmark
[![Dart](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml)


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
  ✓ remove vertex l (6 us)
  ✓ sort edges (32 us)
  ✓ sort edges by weight (33 us)
 Topology:
  ✓ isAcyclic (20 us)
  ✓ topologicalOrdering (31 us)
  ✓ sortedTopologicalOrdering (41 us)
  ✓ transitiveClosure (244 us)
  ✓ cycleVertex (19 us)
  ✓ cycle (19 us)
  ✓ localSources (42 us)
  ✓ stronglyConnectedComponents (40 us)
  ✓ shortestPaths (10 us)
 Selecting path by weight:
  ✓ lightest path a -> g (34 us)
  ✓ heaviest path a -> g (34 us)

 DONE  ./benchmark/bin/graph_crawler_benchmark.dart (1 s)
 Topology:
  ✓ path (20 us)
  ✓ paths (20 us)
  ✓ tree (11 us)
  ✓ mappedTree (18 us)

 DONE  ./benchmark/bin/directed_graph_benchmark.dart (2 s)
 Manipulating edges:
  ✓ remove vertex l (6 us)
  ✓ sort edges (15 us)
 Topology:
  ✓ isAcyclic (17 us)
  ✓ topologicalOrdering (25 us)
  ✓ sortedTopologicalOrdering (38 us)
  ✓ transitiveClosure (75 us)
  ✓ cycleVertex (15 us)
  ✓ cycle (15 us)
  ✓ localSources (38 us)
  ✓ stronglyConnectedComponents (36 us)
  ✓ shortestPaths (8 us)

Benchmark suites: 3 passed, 3 total
Benchmarks:       29 passed, 29 total
Time:             7 s
Ran all benchmark suites.
```

The report above was generated on a PC with an Intel Core i5-6260U processor and 32GB of memory
using the package [`benchmark`][benchmark].




## Features and bugs
Please file feature requests and bugs at the [issue tracker].


[benchmark]: https://pub.dev/packages/benchmark

[issue tracker]: https://github.com/simphotonics/directed_graph/issues

[directed_graph]: https://pub.dev/packages/directed_graph