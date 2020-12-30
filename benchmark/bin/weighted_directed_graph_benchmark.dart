import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:directed_graph/src/utils/color_utils.dart';

int comparator(
  String s1,
  String s2,
) {
  return s1.compareTo(s2);
}

int sum(int left, int right) => left + right;

/// Directed graph benchmark graph setup.
class WeightedDirectedGraphBenchmark extends BenchmarkBase {
  WeightedDirectedGraphBenchmark(String name)
      : graph = WeightedDirectedGraph<String, int>(
          {
            'a': {'b': 1, 'h': 7, 'c': 2, 'e': 40},
            'b': {'h': 6},
            'c': {'h': 5, 'g': 4},
            'd': {'e': 1, 'f': 2},
            'e': {'g': 2},
            'f': {'i': 3},
            'i': {'l': 3, 'k': 2},
            'k': {'g': 4, 'f': 5},
            'l': {'l': 0}
          },
          summation: sum,
          zero: 0,
          comparator: comparator,
        ),
        super(name);

  final WeightedDirectedGraph<String, int> graph;

  /// Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {}

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('$name'));
    print(green('$graph'));
  }
}

class MinWeightPath extends WeightedDirectedGraphBenchmark {
  MinWeightPath(String name) : super(name);

  late List<String> optimalPath;

  /// The benchmark code.
  @override
  void run() {
    optimalPath = graph.optimalPath('d', 'l', extremum: Extremum.min);
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\n$name'));
    print(green(optimalPath.toString()));
  }
}

class LightestPath extends WeightedDirectedGraphBenchmark {
  LightestPath(String name) : super(name);

  late List<String> lightestPath;

  /// The benchmark code.
  @override
  void run() {
    lightestPath = graph.lightestPath('d', 'l');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\n$name'));
    print(green(lightestPath.toString()));
  }
}

class GraphManipulation extends WeightedDirectedGraphBenchmark {
  GraphManipulation(String name) : super(name);

  /// The benchmark code.
  @override
  void run() {
    graph.remove('h');
    graph.addEdges('a', {'h'});
    graph.addEdges('b', {'h'});
    graph.addEdges('c', {'h'});
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nAdding/Removing Edges ... '));
    print(green(graph.toString()));
  }
}

void main() {
  final weightedGraph = WeightedDirectedGraphBenchmark('Print Weighted Graph:');
  final minPath = MinWeightPath('Min Weight Path d => l. ');
  final lightestPath = LightestPath('Lightest Path d => l. ');
  final graphManipulation = GraphManipulation('Adding/Removing Edges');
  weightedGraph.report();
  graphManipulation.report();
  minPath.report();
  lightestPath.report();
}
