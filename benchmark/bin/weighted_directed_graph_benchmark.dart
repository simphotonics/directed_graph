import 'package:benchmark/benchmark.dart';
import 'package:directed_graph/directed_graph.dart';

int comparator(
  String s1,
  String s2,
) {
  return s1.compareTo(s2);
}

int inverseComparator(
  String s1,
  String s2,
) {
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

var graph = WeightedDirectedGraph<String, int>(
  {},
  summation: sum,
  zero: 0,
);

int sum(int left, int right) => left + right;

void main() {
  setUp(() {
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
  });

  group('Manipulating edges:', () {
    benchmark('remove vertex l', () {
      graph.remove(l);
      graph.addEdges(i, {l: 3});
    }, duration: Duration(milliseconds:100));
    benchmark('sort edges', () {
      graph.sortEdges();
    }, duration: Duration(milliseconds:100));
    benchmark('sort edges by weight', () {
      graph.sortEdgesByWeight();
    }, duration: Duration(milliseconds:100));
  });
  group('Topology:', () {
    benchmark('isAcyclic', () {
      graph.isAcyclic;
    }, duration: Duration(milliseconds:100));
    benchmark('topologicalOrdering', () {
      graph.topologicalOrdering;
    }, duration: Duration(milliseconds:100));
    benchmark('sortedTopologicalOrdering', () {
      graph.sortedTopologicalOrdering;
    }, duration: Duration(milliseconds:100));
    benchmark('transitiveClosure', () {
      WeightedDirectedGraph.transitiveClosure(graph);
    }, duration: Duration(milliseconds:100));
    benchmark('cycleVertex', () {
      graph.cycleVertex;
    }, duration: Duration(milliseconds:100));
    benchmark('cycle', () {
      graph.cycle;
    }, duration: Duration(milliseconds:100));
    benchmark('localSources', () {
      graph.localSources;
    }, duration: Duration(milliseconds:100));
    benchmark('stronglyConnectedComponents', () {
      graph.stronglyConnectedComponents;
    }, duration: Duration(milliseconds:100));
    benchmark('shortestPaths', () {
      graph.shortestPaths(a);
    }, duration: Duration(milliseconds:100));
  });
  group('Selecting path by weight:', () {
    benchmark('lightest path a -> g', () {
      graph.lightestPath(a, g);
    }, duration: Duration(milliseconds:100));
    benchmark('heaviest path a -> g', () {
      graph.heaviestPath(a, g);
    }, duration: Duration(milliseconds:100));
  });
}
