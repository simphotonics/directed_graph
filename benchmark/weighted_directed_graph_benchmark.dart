import 'package:benchmark_runner/benchmark_runner.dart';
import 'package:directed_graph/directed_graph.dart';

int comparator(String s1, String s2) {
  return s1.compareTo(s2);
}

int inverseComparator(String s1, String s2) {
  return -s1.compareTo(s2);
}

var a = 'a';
var b = 'b';
var c = 'c';
var d = 'd';
var e = 'e';
var f = 'f';
var g = 'g';
var h = 'h';
var i = 'i';
var k = 'k';
var l = 'l';

var graph = WeightedDirectedGraph<String, int>({}, summation: sum, zero: 0);

int sum(int left, int right) => left + right;

void main() {
  void setup() {
    graph = WeightedDirectedGraph<String, int>(
      {
        'a': {'b': 1, 'h': 7, 'c': 2, 'e': 4},
        'b': {'h': 6},
        'c': {'h': 5, 'g': 4},
        'd': {'e': 1, 'f': 2},
        'e': {'g': 2},
        'f': {'i': 3},
        'i': {'l': 3},
        'k': {'g': 4, 'f': 5},
      },
      summation: sum,
      zero: 0,
      comparator: comparator,
    );
  }

  group('Manipulating edges:', () {
    benchmark('remove vertex l', () {
      graph.remove(l);
      graph.addEdges(i, {l: 3});
    }, setup: setup);
    benchmark('sort edges', () {
      graph.sortEdges();
    }, setup: setup);
    benchmark('sort edges by weight', () {
      graph.sortEdgesByWeight();
    }, setup: setup);
  });
  group('Topology:', () {
    benchmark('isAcyclic', () {
      graph.isAcyclic;
    }, setup: setup);
    benchmark('topologicalOrdering', () {
      graph.topologicalOrdering();
    }, setup: setup);
    benchmark('sortedTopologicalOrdering', () {
      graph.topologicalOrdering();
    }, setup: setup);
    benchmark('transitiveClosure', () {
      WeightedDirectedGraph.transitiveClosure(graph);
    }, setup: setup);
    benchmark('cycleVertex', () {
      graph.cycleVertex;
    }, setup: setup);
    benchmark('cycle', () {
      graph.cycle();
    }, setup: setup);
    benchmark('localSources', () {
      graph.localSources;
    }, setup: setup);
    benchmark('stronglyConnectedComponents', () {
      graph.stronglyConnectedComponents();
    }, setup: setup);
    benchmark('shortestPaths', () {
      graph.shortestPaths(a);
    }, setup: setup);
  });
  group('Selecting path by weight:', () {
    benchmark('lightest path a -> g', () {
      graph.lightestPath(a, g);
    }, setup: setup);
    benchmark('heaviest path a -> g', () {
      graph.heaviestPath(a, g);
    }, setup: setup);
  });
}
