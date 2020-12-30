import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:directed_graph/src/utils/color_utils.dart';

int comparator(
  String s1,
  String s2,
) {
  return s1.compareTo(s2);
}

/// Directed graph benchmark graph setup.
class GraphCrawlerBenchmark extends BenchmarkBase {
  GraphCrawlerBenchmark(String name)
      : graph = DirectedGraph({
          'a': {'b', 'h', 'c', 'e', 'd'},
          'b': {'h'},
          'c': {'h', 'g'},
          'd': {'e', 'f'},
          'e': {'g'},
          'f': {'i'},
          'i': {'l', 'k'},
          'k': {'g', 'f'},
          'l': {'l'},
        }, comparator: comparator),
        super(name);

  DirectedGraph<String> graph;

  /// Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {}

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('InDegreeMap:'));
    print(green('${graph.inDegreeMap}'));
  }
}

class ShortestPaths extends GraphCrawlerBenchmark {
  ShortestPaths(String name) : super(name);

  late Map<String, List<String>> shortestPaths;

  /// The benchmark code.
  @override
  void run() {
    shortestPaths = graph.shortestPaths('a');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nShortest Paths with root \'a\'... '));
    print(green(shortestPaths.toString()));
  }
}

class PathsBenchmark extends GraphCrawlerBenchmark {
  PathsBenchmark(String name) : super(name);

  List<List<String>>? paths;
  var path = <String>[];
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();
    crawler = GraphCrawler(graph.edges);
  }

  /// The benchmark code.
  @override
  void run() {
    path = crawler!.path('a', 'l');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ncrawler.path(a, l) ... '));
    print(green(path.toString()));
  }
}

class SimpleTreeBenchmark extends GraphCrawlerBenchmark {
  SimpleTreeBenchmark(String name) : super(name);

  List<Set<String>>? simpleTree;
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();
    crawler = GraphCrawler(graph.edges);
  }

  /// The benchmark code.
  @override
  void run() {
    simpleTree = crawler!.simpleTree('a');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ncrawler.simpleTree(a) ... '));
    print(green(simpleTree.toString()));
  }
}

class TreeMapBenchmark extends GraphCrawlerBenchmark {
  TreeMapBenchmark(String name) : super(name);

  Map<String, List<Set<String>>>? treeMap;
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();
    crawler = GraphCrawler(graph.edges);
  }

  /// The benchmark code.
  @override
  void run() {
    treeMap = crawler!.mappedTree('a');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ncrawler.mapTree(d, target:l) ... '));
    print(green(treeMap.toString()));
  }
}

class WalksBenchmark extends GraphCrawlerBenchmark {
  WalksBenchmark(String name) : super(name);

  List<List<String>>? walks;
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();

    crawler = GraphCrawler(graph.edges);
  }

  /// The benchmark code.
  @override
  void run() {
    walks = crawler!.walks('d', 'l', maxCount: 2);
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ncrawler.walks(d, l, maxCount: 2) ... '));
    print(green(walks.toString()));
  }
}

void main() {
  final inDegreeBenchmark = GraphCrawlerBenchmark('InDegreeMap:');
  final shortestPaths = ShortestPaths('ShortestPaths');
  final simpleTree = SimpleTreeBenchmark('Simple Tree');
  final treeMap = TreeMapBenchmark('Tree Map');
  final pathsBenchmark = PathsBenchmark('PathsTest');
  final walksBenchmark = WalksBenchmark('WalksBenchmark');

  inDegreeBenchmark.report();
  pathsBenchmark.report();
  shortestPaths.report();
  simpleTree.report();
  treeMap.report();
  walksBenchmark.report();
}
