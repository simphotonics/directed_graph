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

var gc = GraphCrawler<String>(graph.edges);

void main() {
  group('Topology:', () {
    benchmark('path', () {
      gc.path(a, g);
    }, duration: Duration(milliseconds:100));
    benchmark('paths', () {
      gc.path(a, g);
    }, duration: Duration(milliseconds:100));
    benchmark('tree', () {
      gc.tree(a);
    }, duration: Duration(milliseconds:100));
    benchmark('mappedTree', () {
      gc.mappedTree(a);
    }, duration: Duration(milliseconds:100));
  });
}
