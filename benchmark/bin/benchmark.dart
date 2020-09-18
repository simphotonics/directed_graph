//import 'package:ansicolor/ansicolor.dart';
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
class DirectedGraphBenchmark extends BenchmarkBase {
  DirectedGraphBenchmark(String name)
      : graph = DirectedGraph({
          'a': {'b', 'h', 'c', 'e'},
          'b': {'h'},
          'c': {'h', 'g'},
          'd': {'e', 'f'},
          'e': {'g'},
          'f': {'i'},
          'i': {'l'},
          'k': {'g', 'f'},
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

class TopologicalOrderKahn extends DirectedGraphBenchmark {
  TopologicalOrderKahn(String name) : super(name);

  List<String>? topologicalOrdering = [];

  /// The benchmark code.
  @override
  void run() {
    topologicalOrdering = graph.sortedTopologicalOrdering;
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nTopological Ordering Kahn ... '));
    print(green(topologicalOrdering.toString()));
  }
}

class TopologicalOrderDFS extends DirectedGraphBenchmark {
  TopologicalOrderDFS(String name) : super(name);

  List<String>? topologicalOrdering = [];

  /// The benchmark code.
  @override
  void run() {
    topologicalOrdering = graph.topologicalOrdering;
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nTopological Ordering DFS ... '));
    print(green(topologicalOrdering.toString()));
  }
}

// class StronglyConnectedComponents extends DirectedGraphBenchmark {
//   StronglyConnectedComponents(String name) : super(name);

//   List<List<String>> stronglyConnectedComponents;

//   /// The benchmark code.
//   @override
//   void run() {
//     stronglyConnectedComponents = graph.stronglyConnectedComponents;
//   }

//   /// Not measured teardown code executed after the benchmark runs.
//   @override
//   void teardown() {
//     print(magenta('\nStrongly Connected Components Tarjan ... '));
//     print(green(stronglyConnectedComponents.toString()));
//   }
// }

class LocalSources extends DirectedGraphBenchmark {
  LocalSources(String name) : super(name);

  List<List<String>>? localSources;

  /// The benchmark code.
  @override
  void run() {
    localSources = graph.localSources;
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nLocal Sources ... '));
    print(green(localSources.toString()));
  }
}

class GraphManipulation extends DirectedGraphBenchmark {
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
    print(magenta('\nTest Graph ... '));
    print(green(graph.toString()));
  }
}

// class ShortestPath extends DirectedGraphBenchmark {
//   ShortestPath(String name) : super(name);

//   /// The benchmark code.
//   @override
//   void run() {
//     graph.shortestPath('d', 'l');
//   }

//   /// Not measured teardown code executed after the benchmark runs.
//   @override
//   void teardown() {
//     print(magenta('\nShortest Path (graphs)import 'package:directed_graph/graph_crawler.dart'; ... '));
//     print(green(graph.shortestPath('d', 'l').toString()));
//   }
// }

class PathsBenchmark extends DirectedGraphBenchmark {
  PathsBenchmark(String name) : super(name);

  List<List<String>>? paths;
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();
    graph.addEdges('i', {'k'});
    crawler = GraphCrawler(graph.edges);
  }

  /// The benchmark code.
  @override
  void run() {
    paths = crawler!.paths('d', 'l');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ncrawler!.paths(d, l) ... '));
    print(green(paths.toString()));
    graph.removeEdges('i', {'k'});
  }
}

class GraphCycle extends DirectedGraphBenchmark {
  GraphCycle(String name) : super(name);

  List<String>? paths;

  @override
  void setup() {
    super.setup();
    graph.addEdges('i', {'k'});
  }

  /// The benchmark code.
  @override
  void run() {
    paths = graph.cycle;
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ngraph.cycle ... '));
    print(green(paths.toString()));
    graph.removeEdges('i', {'k'});
  }
}

class FastPathsBenchmark extends DirectedGraphBenchmark {
  FastPathsBenchmark(String name) : super(name);

  List<List<String>>? paths;
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();
    graph.addEdges('i', {'k'});
    crawler = GraphCrawler(graph.edges);
  }

  /// The benchmark code.
  @override
  void run() {
    paths = crawler!.fastPaths('d', 'l');
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\ncrawler!.fastPaths(d,l) ... '));
    print(green(paths.toString()));
    graph.removeEdges('i', {'k'});
  }
}

class WalksBenchmark extends DirectedGraphBenchmark {
  WalksBenchmark(String name) : super(name);

  List<List<String>>? walks;
  GraphCrawler<String>? crawler;

  @override
  void setup() {
    super.setup();
    graph.addEdges('i', {'k'});
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
    print(magenta('\ncrawler!.walks(d, l, maxCount: 2) ... '));
    print(green(walks.toString()));
    graph.removeEdges('i', {'k'});
  }
}

void main() {
  var inDegreeBenchmark = DirectedGraphBenchmark('InDegreeMap:');
  var topDFSBenchmark = TopologicalOrderDFS('Topological Ordering DFS:');
  var topKahnBenchmark = TopologicalOrderKahn('Topological Ordering Kahn');
  // var sccBenchmark =
  //     StronglyConnectedComponents('Strongly Connected Componets Tarjan:');
  var localSourcesBenchmark = LocalSources('Local Sources:');
  var graphManipulation = GraphManipulation('Removing/Adding Vertices');
  // var shortestPath = ShortestPath('ShortestPath');
  var pathsBenchmark = PathsBenchmark('PathsTest');
  var graphCycle = GraphCycle('GraphCycle');
  var fastPathsBenchmark = FastPathsBenchmark('FastPaths');
  var walksBenchmark = WalksBenchmark('WalksBenchmark');

  inDegreeBenchmark.report();
  topDFSBenchmark.report();
  topKahnBenchmark.report();
  // sccBenchmark.report();
  localSourcesBenchmark.report();
  graphManipulation.report();
  // shortestPath.report();
  pathsBenchmark.report();
  fastPathsBenchmark.report();
  walksBenchmark.report();
  graphCycle.report();
}
