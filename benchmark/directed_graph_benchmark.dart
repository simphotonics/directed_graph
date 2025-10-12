// ignore_for_file: unused_local_variable

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

void main() {
  var graph = DirectedGraph<String>({
    a: {b, h, c, e},
    d: {e, f},
    b: {h},
    c: {h, g},
    f: {i},
    i: {l},
    // h: {a},
    k: {g, f},
  }, comparator: comparator);
  for (var i = 1; i < 0; i++) {
    var nodes = graph.vertices.toList();
    for (var node in nodes) {
      graph.addEdges(node, {'$node$i'});
    }
  }

  group('Manipulating edges:', () {
    benchmark('remove and add vertex l', () {
      graph.remove(l);
      graph.addEdges(i, {l});
    });
    benchmark('sort edges', () {
      graph.sortEdges();
    });
  });
  group('Topology', () {
    benchmark('isAcyclic', () {
      graph.isAcyclic;
    });
    benchmark('topologicalOrdering', () {
      graph.topologicalOrdering();
    });
    benchmark('sortedTopologicalOrdering', () {
      graph.topologicalOrdering(sorted: true);
    });
    benchmark('transitiveClosure', () {
      DirectedGraph.transitiveClosure(graph);
    });
    benchmark('cycleVertex', () {
      graph.cycleVertex;
    });
    benchmark('cycle', () {
      graph.cycle();
    });
    benchmark('localSources', () {
      graph.localSources();
    });
    benchmark('stronglyConnectedComponents', () {
      graph.stronglyConnectedComponents();
    });
    benchmark('shortestPaths', () {
      graph.shortestPaths(a);
    });
    benchmark('shortestPath', () {
      graph.shortestPath(a, g);
    });
    benchmark('path', () {
      graph.path(a, g);
    });
    benchmark('reachableVertices(d)', () {
      graph.reachableVertices(d);
    });
  });
  group('Comparator', () {
    final count = 10000000;
    final graph = DirectedGraph<String>(<String, Set<String>>{});
    final inferedComparator = graph.comparator;

    benchmark('user defined', () {
      var result = 0;
      for (var i = 0; i < count; i++) {
        result = comparator('Hello', 'world');
      }
    });
    benchmark('infered', () {
      if (graph.hasComparator) {
        var result = 0;
        for (var i = 0; i < count; i++) {
          result = inferedComparator!('Hello', 'world');
        }
      }
    });
  });
}
