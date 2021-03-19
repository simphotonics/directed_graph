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

var graph = DirectedGraph<String>(
  {
    a: {b, h, c, e},
    d: {e, f},
    b: {h},
    c: {h, g},
    f: {i},
    i: {l},
    k: {g, f}
  },
  comparator: comparator,
);

void main() {
  setUp(() {
    graph = DirectedGraph<String>(
      {
        a: {b, h, c, e},
        d: {e, f},
        b: {h},
        c: {h, g},
        f: {i},
        i: {l},
        k: {g, f}
      },
      comparator: comparator,
    );
  });

  group('Manipulating edges:', () {
    benchmark('remove vertex l', () {
      graph.remove(l);
      graph.addEdges(i, {l});
    }, duration: Duration(milliseconds: 100));
    benchmark('sort edges', () {
      graph.sortEdges();
    }, duration: Duration(milliseconds: 100));
  });
  group('Topology:', () {
    benchmark('isAcyclic', () {
      graph.isAcyclic;
    }, duration: Duration(milliseconds: 100));
    benchmark('topologicalOrdering', () {
      graph.topologicalOrdering;
    }, duration: Duration(milliseconds: 100));
    benchmark('sortedTopologicalOrdering', () {
      graph.sortedTopologicalOrdering;
    }, duration: Duration(milliseconds: 100));
    benchmark('transitiveClosure', () {
      DirectedGraph.transitiveClosure(graph);
    }, duration: Duration(milliseconds: 100));
    benchmark('cycleVertex', () {
      graph.cycleVertex;
    }, duration: Duration(milliseconds: 100));
    benchmark('cycle', () {
      graph.cycle;
    }, duration: Duration(milliseconds: 100));
    benchmark('localSources', () {
      graph.localSources;
    }, duration: Duration(milliseconds: 100));
    benchmark('stronglyConnectedComponents', () {
      graph.stronglyConnectedComponents;
    }, duration: Duration(milliseconds: 100));

    benchmark('shortestPaths', () {
      graph.shortestPaths(a);
    }, duration: Duration(milliseconds: 100));
    benchmark('reachableVertices(d)', () {
      graph.reachableVertices(d);
    }, duration: Duration(milliseconds: 100));
  });
}
