import 'package:directed_graph/directed_graph.dart';
import 'package:minimal_test/minimal_test.dart';

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

  final emptyGraph = BidirectedGraph({});

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
    test('get comparator', () {
      expect(graph.comparator, comparator);
    });
    test('set comparator.', () {
      graph.comparator = inverseComparator;
      expect(graph.comparator, inverseComparator);
      expect(graph.vertices, [l, k, i, h, g, f, e, d, c, b, a]);
      graph.comparator = comparator;
    });
    test('for loop.', () {
      var index = 0;
      for (var vertex in graph) {
        expect(vertex, graph.vertices[index]);
        ++index;
      }
    });
  });

  group('Manipulating edges/vertices.', () {
    test('addEdges():', () {
      expect(graph.edges(i), {l, f});
      expect(graph.edges(k), {g, f});
      graph.addEdges(i, {k});
      expect(graph.edges(i), {l, f, k});
      expect(graph.edges(k), {g, f, i});
      graph.removeEdges(i, {k});
      expect(graph.edges(i), {l, f});
      expect(graph.edges(k), {g, f});
    });
    test('remove().', () {
      expect(graph.edges(i), {l, f});
      graph.remove(l);
      expect(graph.edges(i), {f});
      expect(graph.vertices.contains(l), false);
      // Restore graph:
      graph.addEdges(i, {l});
      expect(graph.vertices.contains(l), true);
      expect(graph.edges(i), {f, l});
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
      graph.addEdges(l, {l});
      expect(graph.inDegree(l), 2);
      graph.removeEdges(l, {l});
      expect(graph.inDegree(l), 1);
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
    test('vertices().', () {
      expect(graph.vertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
  group('Topological ordering:', () {
    test('isAcyclic: self-loop.', () {
      graph.addEdges(l, {l});
      expect(
        graph.isAcyclic,
        false,
      );
      graph.removeEdges(l, {l});
    });
    test('isAcyclic: without self-loops', () {
      expect(graph.isAcyclic, false);
    });
    test('isAcyclic: empty graph', () {
      expect(emptyGraph.isAcyclic, true);
    });
    test('sortedTopologicalOrdering:', () {
      expect(graph.sortedTopologicalOrdering, null);
    });
    test('topologicalOrdering:', () {
      expect(graph.topologicalOrdering, null);
    });
    test('topologicalOrdering: empty graph', () {
      expect(BidirectedGraph<int>({}).topologicalOrdering, <int>{});
    });
    test('localSources().', () {
      expect(graph.localSources, null);
    });
  });
  group('Cycles', () {
    test('graph.cycle | acyclic graph.', () {
      expect(graph.cycle, [a, b, a]);
    });
    test('emptyGraph.cycle', () {
      expect(emptyGraph.cycle, []);
    });

    test('graph.cycle | cyclic graph.', () {
      graph.addEdges(a, {a});
      expect(graph.cycle, [a, a]);
      graph.removeEdges(a, {a});
    });

    test('graph.cycle | non-trivial cycle.', () {
      final crawler = GraphCrawler<String>(graph.edges);
      expect(crawler.path(f, f), [f, i, f]);
    });
  });
  group('TransitiveClosure', () {
    test('cyclic graph', () {
      final tc = BidirectedGraph.transitiveClosure(graph)..sortEdges();

      expect(tc.graphData, {
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
