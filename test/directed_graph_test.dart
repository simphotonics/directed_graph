import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

/// To run the test, navigate to the folder 'directed_graph'
/// in your local copy of this library and use the command:
///
/// # pub run test -r expanded --test-randomize-ordering-seed=random
///
void main() {
  int comparator(String s1, String s2) {
    return s1.compareTo(s2);
  }

  int inverseComparator(String s1, String s2) {
    return -s1.compareTo(s2);
  }

  const a = 'a';
  const b = 'b';
  const c = 'c';
  const d = 'd';
  const e = 'e';
  const f = 'f';
  const g = 'g';
  const h = 'h';
  const i = 'i';
  const k = 'k';
  const l = 'l';

  // Original graph
  final graph0 = DirectedGraph<String>({
    a: {b, h, c, e},
    d: {e, f},
    b: {h},
    c: {h, g},
    f: {i},
    i: {l},
    k: {g, f},
  }, comparator: comparator);

  group('Basic:', () {
    test('toString().', () {
      final graph = DirectedGraph.of(graph0);
      expect(
        graph.toString(),
        '{\n'
        ' \'a\': {\'b\', \'h\', \'c\', \'e\'},\n'
        ' \'b\': {\'h\'},\n'
        ' \'h\': {},\n'
        ' \'c\': {\'h\', \'g\'},\n'
        ' \'e\': {},\n'
        ' \'g\': {},\n'
        ' \'d\': {\'e\', \'f\'},\n'
        ' \'f\': {\'i\'},\n'
        ' \'i\': {\'l\'},\n'
        ' \'l\': {},\n'
        ' \'k\': {\'g\', \'f\'},\n'
        '}',
      );
    });
    test('get comparator', () {
      expect(graph0.comparator, comparator);
    });
    test('default comparator', () {
      final graph = DirectedGraph<num>({
        1: {2}
      });
      expect(graph.comparator, isA<Comparator<num>>());
    });
    test('null comparator', () {
      final graph = DirectedGraph<num>({
        1: {2}
      })
        ..comparator = null;

      expect(graph.comparator, equals(null));
    });

    test('set comparator.', () {
      final graph = DirectedGraph.of(graph0);
      graph.comparator = inverseComparator;
      expect(graph.comparator, inverseComparator);
      expect(graph.sortedVertices.toList(), [l, k, i, h, g, f, e, d, c, b, a]);
    });
    test('for loop.', () {
      var index = 0;
      final graph = DirectedGraph.of(graph0);
      final vertices = graph.vertices.toList();
      for (var vertex in graph) {
        expect(vertex, vertices[index]);
        ++index;
      }
    });
  });

  group('Manipulating edges/vertices.', () {
    test('addEdges():', () {
      final graph = DirectedGraph.of(graph0);
      graph.addEdges(i, {k});
      expect(graph.edges(i), {l, k});
      '{\n'
          ' a: [b, h, c, e],\n'
          ' b: [h],\n'
          ' c: [h, g],\n'
          ' d: [e, f],\n'
          ' e: [],\n'
          ' f: [i],\n'
          ' g: [],\n'
          ' h: [],\n'
          ' i: {l},\n'
          ' k: [g, f],\n'
          ' l: [],\n'
          '}';
    });
    test('remove(l).', () {
      final graph = DirectedGraph.of(graph0);
      graph.remove(l);
      expect(graph.edges(i), <String>{});
      expect(graph.sortedVertices.toList(), [
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'k',
      ]);
    });
    test('clear', () {
      final graph = DirectedGraph.of(graph0);
      expect(graph.sortedVertices, graph0.sortedVertices);
      graph.clear();
      expect(graph.isEmpty, true);
    });
  });
  group('Graph data:', () {
    final graph = DirectedGraph.of(graph0);
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
      expect(graph.outDegreeMap, {
        a: 4,
        b: 1,
        c: 2,
        d: 2,
        e: 0,
        f: 1,
        g: 0,
        h: 0,
        i: 1,
        k: 2,
        l: 0,
      });
    });
    test('inDegreeMap.', () {
      expect(graph.inDegreeMap, {
        a: 0,
        b: 1,
        h: 3,
        c: 1,
        e: 2,
        d: 0,
        f: 2,
        g: 2,
        i: 1,
        l: 1,
        k: 0,
      });
    });
    test('sortedVertices.', () {
      expect(graph.sortedVertices.toList(), [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
  group('Graph topology:', () {
    test('stronglyConnectedComponents().', () {
      final graph = DirectedGraph<String>({
        k: {a},
        a: {},
        b: {c},
        c: {b},
      });
      expect(graph.stronglyConnectedComponents(), [
        {a},
        {k},
        {c, b},
      ]);
    });
    test('stronglyConnectedComponents(sorted: true).', () {
      final graph = DirectedGraph<String>({
        k: {a},
        a: {},
        b: {c},
        c: {b},
      });
      expect(graph.stronglyConnectedComponents(sorted: true), [
        {a},
        {b, c},
        {k},
      ]);
    });

    test(
        'stronglyConnectedComponents(sorted: true, '
        'comparator: inverseComparator).', () {
      final graph = DirectedGraph<String>({
        k: {a},
        a: {},
        b: {c},
        c: {b},
      });
      expect(
        graph.stronglyConnectedComponents(
          sorted: true,
          comparator: inverseComparator,
        ),
        [
          {a},
          {k},
          {c, b},
        ],
      );
    });

    test('shortestPath().', () {
      final graph = DirectedGraph.of(graph0);
      expect(graph.shortestPath(d, l), [d, f, i, l]);
    });

    test('isAcyclic(): self-loop.', () {
      final graph = DirectedGraph.of(graph0);
      graph.addEdges(l, {l});
      expect(graph.isAcyclic, false);
    });
    test('isAcyclic(): without cycles', () {
      final graph = DirectedGraph.of(graph0);
      expect(graph.isAcyclic, true);
    });

    test('topologicalOrdering(): self-loop', () {
      final graph = DirectedGraph.of(graph0);
      graph.addEdges(l, {l});
      expect(graph.topologicalOrdering(), null);
    });
    test('topologicalOrdering(): cycle', () {
      final graph = DirectedGraph.of(graph0);
      graph.addEdges(i, {k});
      expect(graph.topologicalOrdering(), null);
    });
    test('topologicalOrdering():', () {
      final graph = DirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      });
      expect(graph.topologicalOrdering()?.toList(), [d, e, k, c, a, b]);
    });
    test('topologicalOrdering(sorted: true):', () {
      final graph = DirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      });
      expect(graph.topologicalOrdering(sorted: true)?.toList(), [
        d,
        e,
        k,
        a,
        b,
        c,
      ]);
    });
    test(
        'topologicalOrdering(sorted: true, '
        'comparator: inverseComparator):', () {
      final graph = DirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      }, comparator: inverseComparator);
      expect(graph.topologicalOrdering(sorted: true)?.toList(), [
        k,
        e,
        d,
        c,
        b,
        a,
      ]);
    });
    test('topologicalOrdering(): empty graph', () {
      expect(DirectedGraph<int>({}).topologicalOrdering(), <int>{});
    });

    test('reverseTopologicalOrdering():', () {
      final graph = DirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      });
      expect(graph.reverseTopologicalOrdering()?.toList(), [b, a, c, k, e, d]);
    });
    test('reverseTopologicalOrdering(sorted: true):', () {
      final graph = DirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      }, comparator: comparator);
      expect(graph.reverseTopologicalOrdering(sorted: true)?.toList(), [
        a,
        b,
        c,
        d,
        e,
        k,
      ]);
    });
    test(
        'topologicalOrdering(sorted: true, '
        'comparator: inverseComparator):', () {
      final graph = DirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      }, comparator: inverseComparator);
      expect(graph.reverseTopologicalOrdering(sorted: true)?.toList(), [
        c,
        b,
        a,
        k,
        e,
        d,
      ]);
    });
    test('localSources().', () {
      final graph = DirectedGraph.of(graph0);
      expect(graph.localSources(), [
        [a, d, k],
        [b, c, e, f],
        [g, h, i],
        [l],
      ]);
    });
  });
  group('Cycles', () {
    test('graph.cycle | acyclic graph.', () {
      final graph = DirectedGraph.of(graph0);
      expect(graph.cycle(), <String>[]);
    });

    test('graph.cycle | cyclic graph.', () {
      final graph = DirectedGraph.of(graph0);
      graph.addEdges(l, {l});
      expect(graph.cycle(), [l, l]);
    });

    test('graph.cycle | non-trivial cycle.', () {
      final graph = DirectedGraph.of(graph0);
      graph.addEdges(i, {k});
      expect(graph.cycle(), [f, i, k, f]);
    });
  });
  group('TransitiveClosure', () {
    test('acyclic graph', () {
      final graph = DirectedGraph.of(graph0);
      expect(DirectedGraph.transitiveClosure(graph).data, <String, Set<String>>{
        a: {b, h, c, g, e},
        b: {h},
        c: {h, g},
        d: {e, f, i, l},
        e: {},
        f: {i, l},
        g: {},
        h: {},
        i: {l},
        k: {g, f, i, l},
        l: {},
      });
    });
  });
  group('Default comparator', () {
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
    });
    test('sort Strings', () {
      for (var vertex in graph.sortedVertices) {
        vertex = '${vertex}1';
      }
      expect(graph.sortedVertices, {
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'k',
        'l',
      });
    });
  });
}
