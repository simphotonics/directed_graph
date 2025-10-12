
# Directed Graph - Benchmark
[![Dart](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml)


## Running the benchmarks

To run the benchmarks, navigate to the package root in your local copy of [`directed_graph`][directed_graph] and
use the command:
```
dart run benchmark_runner report
```
A sample benchmark output is shown below:

```Console
$ dart run benchmark_runner report benchmark/directed_graph_benchmark.dart

Finding benchmark files ...
  benchmark/directed_graph_benchmark.dart

$ dart benchmark/directed_graph_benchmark.dart
  [097ms:565us] Manipulating edges: remove and add vertex l
    mean: 1.17 ± 1.32 us, median: 0.88 ± 0.067 us
    ______▉▁_▁_▁_________  450  _____
    sample size: 124 (averaged over 132 runs)

  [091ms:622us] Manipulating edges: sort edges
    mean: 1.65 ± 0.21 us, median: 1.56 ± 0.20 us
    ▉▂▄___▁______
    sample size: 145 (averaged over 163 runs)

  [005ms:529us] Topology: isAcyclic
    mean: 0.0099 ± 0.014 us, median: 0.0050 ± 0.00 us
    ▉___
    sample size: 257 (averaged over 334 runs)

  [125ms:280us] Topology: topologicalOrdering
    mean: 2.68 ± 0.87 us, median: 2.44 ± 0.19 us
    ▉▆▁▁_▁__▁_____  65  _____
    sample size: 104 (averaged over 105 runs)

  [113ms:285us] Topology: sortedTopologicalOrdering
    mean: 2.57 ± 0.19 us, median: 2.48 ± 0.18 us
    ▉▉__▁▁▁▁____
    sample size: 144 (averaged over 162 runs)

  [181ms:045us] Topology: transitiveClosure
    mean: 6.35 ± 0.49 us, median: 6.071 ± 0.79 us
    ▉▂▃___
    sample size: 100 (averaged over 98 runs)

  [002ms:843us] Topology: cycleVertex
    mean: 0.0098 ± 0.012 us, median: 0.0050 ± 0.00100 us
    ▉___________________  505  _____
    sample size: 295 (averaged over 392 runs)

  [004ms:596us] Topology: cycle
    mean: 0.021 ± 0.033 us, median: 0.013 ± 0.00100 us
    ▄__▉___________________  1162  _____
    sample size: 286 (averaged over 378 runs)

  [163ms:180us] Topology: localSources
    mean: 5.19 ± 2.36 us, median: 4.26 ± 1.26 us
    ▉▇▁▁___▁_________________
    sample size: 132 (averaged over 144 runs)

  [125ms:866us] Topology: stronglyConnectedComponents
    mean: 3.18 ± 0.29 us, median: 3.17 ± 0.44 us
    ▉▁▅▃▁_____
    sample size: 138 (averaged over 152 runs)

  [111ms:963us] Topology: shortestPaths
    mean: 2.33 ± 1.26 us, median: 1.82 ± 0.92 us
    ▉▇▂▁_▁▁_________________
    sample size: 171 (averaged over 203 runs)

  [055ms:084us] Topology: shortestPath
    mean: 0.78 ± 0.60 us, median: 0.61 ± 0.26 us
    ▉▁▁▂_____________  54  _____
    sample size: 178 (averaged over 214 runs)

  [048ms:600us] Topology: path
    mean: 0.65 ± 0.093 us, median: 0.60 ± 0.11 us
    ▉___▁_▁_____
    sample size: 221 (averaged over 281 runs)

  [056ms:204us] Topology: reachableVertices(d)
    mean: 0.79 ± 0.16 us, median: 0.72 ± 0.030 us
    ▇▉_______________  64  _____
    sample size: 176 (averaged over 211 runs)

  [01s:302ms] Comparator: user defined
    mean: 72.0069 ± 6.84 ms, median: 68.40 ± 11.15 ms
    ▉▂▃▂
    sample size: 15

  [02s:347ms] Comparator: infered
    mean: 213.33 ± 3.99 ms, median: 212.90 ± 4.10 ms
    ▁▉▅▁
    sample size: 10


-------      Summary     --------
Total run time: [06s:215ms]
Completed benchmarks: 16.
Completed successfully.
Exiting with code: 0.

```


The report above was generated on a PC with an Intel Core i5-6260U processor and 32GB of memory
using the package [`benchmark_runner`][benchmark_runner].




## Features and bugs
Please file feature requests and bugs at the [issue tracker].


[benchmark_runner]: https://pub.dev/packages/benchmark_runner

[issue tracker]: https://github.com/simphotonics/directed_graph/issues

[directed_graph]: https://pub.dev/packages/directed_graph