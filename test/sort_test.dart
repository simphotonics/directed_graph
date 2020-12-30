import 'package:directed_graph/directed_graph.dart';
import 'package:minimal_test/minimal_test.dart';

void main(List<String> args) {
  int comparator(
    String s1,
    String s2,
  ) {
    return s1.compareTo(s2);
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

  group('Set', () {
    test('edges(a):', () {
      expect(graph.edges(a).toSet()..sort(comparator), {b, c, e, h});
    });
  });
  group('Map', () {
    test('{c:3, a:1, b:2}', () {
      expect({c: 3, a: 1, b: 2}..sort(comparator), {a: 1, b: 2, c: 3});
    });
  });
}
