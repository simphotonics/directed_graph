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

var graph = DirectedGraph<String>({
  a: {b, h, c, e},
  d: {e, f},
  b: {h},
  c: {h, g},
  f: {i},
  i: {l},
  k: {g, f},
}, comparator: comparator);

final gc = graph.crawler;

void main() {
  final nodes = {a, b};

  for (var i = 0; i < 1; i++) {
    for (var node in nodes) {
      graph.addEdges(node, {'$node$i'});
      graph.addEdges('$node$i', nodes);
    }
  }

  group('Topology:', () {
    benchmark('path', () {
      gc.path(a, g);
    });
    benchmark('paths', () {
      gc.paths(a, g);
    });
    benchmark('tree', () {
      gc.tree(a);
    });

    benchmark('mappedTree', () {
      gc.mappedTree(a);
    });
    benchmark('shortestPaths', () {
      gc.shortestPaths(a);
    });
    benchmark('reachableVertices', () {
      gc.reachableVertices(a);
    });
  });
}
