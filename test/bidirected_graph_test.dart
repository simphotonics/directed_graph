import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

/// To run the test, navigate to the folder 'directed_graph'
/// in your local copy of this library and use the command:
///
/// # pub run test -r expanded --test-randomize-ordering-seed=random
///
void main() {
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

  var graph = BidirectedGraph<String>(
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

  group('Basic:', () {
    test('toString().', () {
      expect(
          graph.toString(),
          '{\n'
          ' \'a\': {\'b\', \'h\', \'c\', \'e\'},\n'
          ' \'b\': {\'h\', \'a\'},\n'
          ' \'c\': {\'h\', \'g\', \'a\'},\n'
          ' \'d\': {\'e\', \'f\'},\n'
          ' \'e\': {\'a\', \'d\'},\n'
          ' \'f\': {\'i\', \'d\', \'k\'},\n'
          ' \'g\': {\'c\', \'k\'},\n'
          ' \'h\': {\'a\', \'b\', \'c\'},\n'
          ' \'i\': {\'l\', \'f\'},\n'
          ' \'k\': {\'g\', \'f\'},\n'
          ' \'l\': {\'i\'},\n'
          '}');
    });
  });

  group('Graph data:', () {
    test('edges().', () {
      expect(graph.edges(a), {b, h, c, e});
    });
    test('indegree().', () {
      expect(graph.inDegree(h), 3);
    });
    test('indegree vertex with self-loop.', () {
      addTearDown(() {
        graph.removeEdges(l, {l});
      });
      graph.addEdges(l, {l});
      expect(graph.inDegree(l), 2);
    });
    test('outDegree().', () {
      expect(graph.outDegree(d), 2);
    });
    test('outDegreeMap().', () {
      expect(graph.outDegreeMap,
          {a: 4, b: 2, c: 3, d: 2, e: 2, f: 3, g: 2, h: 3, i: 2, k: 2, l: 1});
    });
    test('inDegreeMap.', () {
      expect(graph.inDegreeMap,
          {a: 4, b: 2, h: 3, c: 3, e: 2, g: 2, d: 2, f: 3, i: 2, k: 2, l: 1});
    });
    test('sortedVertices.', () {
      expect(graph.sortedVertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });

  group('TransitiveClosure', () {
    test('cyclic graph', () {
      final tc = BidirectedGraph.transitiveClosure(graph)..sortEdges();

      expect(tc.data, {
        a: {a, b, c, d, e, f, g, h, i, k, l},
        b: {a, b, c, d, e, f, g, h, i, k, l},
        c: {a, b, c, d, e, f, g, h, i, k, l},
        d: {a, b, c, d, e, f, g, h, i, k, l},
        e: {a, b, c, d, e, f, g, h, i, k, l},
        f: {a, b, c, d, e, f, g, h, i, k, l},
        g: {a, b, c, d, e, f, g, h, i, k, l},
        h: {a, b, c, d, e, f, g, h, i, k, l},
        i: {a, b, c, d, e, f, g, h, i, k, l},
        k: {a, b, c, d, e, f, g, h, i, k, l},
        l: {a, b, c, d, e, f, g, h, i, k, l}
      });
    });
  });
}
