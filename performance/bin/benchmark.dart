import 'package:ansicolor/ansicolor.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:directed_graph/directed_graph.dart';

AnsiPen magenta = AnsiPen()..magenta(bold: true);
AnsiPen green = AnsiPen()..green(bold: true);
AnsiPen blue = AnsiPen()..blue(bold: true);

int comparator(
  Vertex<String> vertex1,
  Vertex<String> vertex2,
) {
  return vertex1.data.compareTo(vertex2.data);
}

/// Directed graph benchmark graph setup.
class DirectedGraphBenchmark extends BenchmarkBase {
  DirectedGraphBenchmark(this.name) : super(name);

  final String name;
  DirectedGraph<String> graph;
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

  /// Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    this.graph = DirectedGraph({
      a: [b, h, c, e],
      d: [e, f],
      b: [h],
      c: [h, g],
      f: [i],
      i: [l],
      k: [g, f]
    }, comparator: comparator);
  }

  /// Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(blue('InDegreeMap:'));
    print(green('${this.graph.inDegreeMap}'));
  }
}

class TopologicalOrderKahn extends DirectedGraphBenchmark {
  TopologicalOrderKahn(String name) : super(name);

  List<Vertex<String>> topologicalOrdering = [];

  /// The benchmark code.
  @override
  void run() {
    this.topologicalOrdering = this.graph.sortedTopologicalOrdering();
  }

  /// Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nTopological Ordering Kahn ... '));
    print(green(this.topologicalOrdering.toString()));
  }
}

class TopologicalOrderDFS extends DirectedGraphBenchmark {
  TopologicalOrderDFS(String name) : super(name);

  List<Vertex<String>> topologicalOrdering = [];

  /// The benchmark code.
  @override
  void run() {
    this.topologicalOrdering = this.graph.topologicalOrdering();
  }

  /// Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nTopological Ordering DFS ... '));
    print(green(this.topologicalOrdering.toString()));
  }
}

class StronglyConnectedComponents extends DirectedGraphBenchmark {
  StronglyConnectedComponents(String name) : super(name);

  List<List<Vertex<String>>> stronglyConnectedComponents;

  /// The benchmark code.
  @override
  void run() {
    this.stronglyConnectedComponents = this.graph.stronglyConnectedComponents();
  }

  /// Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nStrongly Connected Components Tarjan ... '));
    print(green(this.stronglyConnectedComponents.toString()));
  }
}

class LocalSources extends DirectedGraphBenchmark {
  LocalSources(String name) : super(name);

  List<List<Vertex<String>>> localSources;

  /// The benchmark code.
  @override
  void run() {
    this.localSources = this.graph.localSources();
  }

  /// Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nLocal Sources ... '));
    print(green(this.localSources.toString()));
  }
}

class GraphManipulation extends DirectedGraphBenchmark {
  GraphManipulation(String name) : super(name);

  /// The benchmark code.
  @override
  void run() {
    this.graph.remove(super.h);
    this.graph.addEdges(a, [h]);
    this.graph.addEdges(b, [h]);
    this.graph.addEdges(c, [h]);
  }

  /// Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {
    print(magenta('\nTest Graph ... '));
    print(green(this.graph.toString()));
  }
}

void main() {
  var topDFSBenchmark = TopologicalOrderDFS('Topological Ordering DFS:');
  var topKahnBenchmark = TopologicalOrderKahn('Topological Ordering Kahn');
  var sccBenchmark =
      StronglyConnectedComponents('Strongly Connected Componets Tarjan:');
  var localSourcesBenchmark = LocalSources('Local Sources:');
  var graphManipulation = GraphManipulation('Removing/Adding Vertices');
  topDFSBenchmark.report();
  topKahnBenchmark.report();
  sccBenchmark.report();
  localSourcesBenchmark.report();
  graphManipulation.report();
}
