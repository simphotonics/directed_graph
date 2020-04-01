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

  /// Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    var player = Vertex<String>('Player');
    var match = Vertex<String>('Match');
    var _set = Vertex<String>('Set');
    var game = Vertex<String>('Game');
    var point = Vertex<String>('Point');
    var team = Vertex<String>('Team');
    var tournament = Vertex<String>('Tournament');
    var umpire = Vertex<String>('Umpire');
    var court1 = Vertex<String>('Court 1');
    var grandSlam = Vertex<String>('GrandSlam');

    this.graph = DirectedGraph({
      grandSlam: [tournament, court1],
      tournament: [team, player, match, _set, game, point, umpire],
      team: [player],
      match: [player, umpire],
      _set: [player, match],
      game: [player, _set],
      point: [player, game]
    });
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
    this.topologicalOrdering = this.graph.topologicalOrdering(comparator);
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
    this.topologicalOrdering = this.graph.topologicalOrderingDFS();
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

void main() {
  var topDFSBenchmark = TopologicalOrderDFS('Topological Ordering DFS:');
  var topKahnBenchmark = TopologicalOrderKahn('Topological Ordering Kahn');
  var sccBenchmark =
      StronglyConnectedComponents('Strongly Connected Componets Tarjan:');

  topDFSBenchmark.report();
  topKahnBenchmark.report();
  sccBenchmark.report();

  print(blue('\nThis is the test graph:'));
  print(green(sccBenchmark.graph.toString()));
  print('\n');
}
