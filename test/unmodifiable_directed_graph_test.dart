import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

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

  // Original graph edges
  final edges = {
    a: {b, h, c, e},
    d: {e, f},
    b: {h},
    c: {h, g},
    f: {i},
    i: {l},
    k: {g, f},
  };

  final graph = UnmodifiableDirectedGraph(edges, comparator: comparator);

  group('Basic:', () {
    test('toString().', () {
      expect(
        graph.toString(),
        '{\n'
        ' \'a\': {\'b\', \'h\', \'c\', \'e\'},\n'
        ' \'b\': {\'h\'},\n'
        ' \'h\': {},\n'
        ' \'c\': {\'h\', \'g\'},\n'
        ' \'e\': {},\n'
        ' \'d\': {\'e\', \'f\'},\n'
        ' \'f\': {\'i\'},\n'
        ' \'g\': {},\n'
        ' \'i\': {\'l\'},\n'
        ' \'l\': {},\n'
        ' \'k\': {\'g\', \'f\'},\n'
        '}',
      );
    });
    test('get comparator', () {
      expect(graph.comparator, comparator);
    });
    test('default comparator', () {
      final graph = UnmodifiableDirectedGraph<num>({
        1: {2},
      });
      expect(graph.comparator, isA<Comparator<num>>());
    });
    test('null comparator', () {
      final graph = DirectedGraph<num>({
        1: {2},
      })..comparator = null;

      expect(graph.comparator, equals(null));
    });

    test('set comparator.', () {
      expect(
        () => graph.comparator = inverseComparator,
        throwsA(isA<UnsupportedError>()),
      );
    });
    test('for loop.', () {
      var index = 0;
      final vertices = graph.vertices.toList();
      for (var vertex in graph) {
        expect(vertex, vertices[index]);
        ++index;
      }
    });
  });

  group('Manipulating edges/vertices:', () {
    test('addEdge', () {
      expect(() => graph.addEdge(i, k), throwsA(isA<UnsupportedError>()));
    });

    test('addEdges', () {
      expect(() => graph.addEdges(i, {k, l}), throwsA(isA<UnsupportedError>()));
    });
    test('removeEdge', () {
      expect(() => graph.removeEdge(a, b), throwsA(isA<UnsupportedError>()));
    });
    test('removeEdges', () {
      expect(
        () => graph.removeEdges(a, {b, c}),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('remove(l)', () {
      expect(() => graph.remove(l), throwsA(isA<UnsupportedError>()));
    });
    test('clear', () {
      expect(() => graph.clear(), throwsA(isA<UnsupportedError>()));
    });
    test('clearEdges', () {
      expect(() => graph.clearEdges(), throwsA(isA<UnsupportedError>()));
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
      final g = UnmodifiableDirectedGraph({
        a: {a},
        b: {a},
      });
      expect(g.inDegree(a), 2);
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

    test('stronglyConnectedComponents(sorted: true, '
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
      expect(graph.shortestPath(d, l), [d, f, i, l]);
    });

    test('isAcyclic(): self-loop.', () {
      final g = UnmodifiableDirectedGraph({
        a: {a},
      });
      expect(g.isAcyclic, false);
    });
    test('isAcyclic(): without cycles', () {
      expect(graph.isAcyclic, true);
    });

    test('topologicalOrdering(): self-loop', () {
      final g = UnmodifiableDirectedGraph({
        a: {a},
      });
      expect(g.topologicalOrdering(), null);
    });
    test('topologicalOrdering(): cycle', () {
      final g = UnmodifiableDirectedGraph({
        a: {b},
        b: {c},
        c: {a},
      });
      expect(g.topologicalOrdering(), null);
    });
    test('topologicalOrdering():', () {
      final graph = UnmodifiableDirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      });
      expect(graph.topologicalOrdering()?.toList(), [d, e, k, c, a, b]);
    });
    test('topologicalOrdering(sorted: true):', () {
      final graph = UnmodifiableDirectedGraph<String>({
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
    test('topologicalOrdering(sorted: true, '
        'comparator: inverseComparator):', () {
      final graph = UnmodifiableDirectedGraph<String>({
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
      expect(UnmodifiableDirectedGraph<int>({}).topologicalOrdering(), <int>{});
    });

    test('reverseTopologicalOrdering():', () {
      final graph = UnmodifiableDirectedGraph<String>({
        k: {b, a, c},
        d: {},
        e: {},
      });
      expect(graph.reverseTopologicalOrdering()?.toList(), [b, a, c, k, e, d]);
    });
    test('reverseTopologicalOrdering(sorted: true):', () {
      final graph = UnmodifiableDirectedGraph<String>({
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
    test('topologicalOrdering(sorted: true, '
        'comparator: inverseComparator):', () {
      final graph = UnmodifiableDirectedGraph<String>({
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
      expect(graph.cycle(), <String>[]);
    });

    test('graph.cycle | cyclic graph.', () {
      final g = UnmodifiableDirectedGraph<String>({
        a: {b},
        b: {c},
        c: {a},
      });
      expect(g.cycle(), [a, b, c, a]);
    });
  });
  group('TransitiveClosure', () {
    test('acyclic graph', () {
      expect(
        UnmodifiableDirectedGraph.transitiveClosure(graph).data,
        <String, Set<String>>{
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
        },
      );
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

    var graph = UnmodifiableDirectedGraph<String>({
      a: {b, h, c, e},
      d: {e, f},
      b: {h},
      c: {h, g},
      f: {i},
      i: {l},
      k: {g, f},
    });
    test('sort Strings', () {
      expect(graph.sortedVertices, {a, b, c, d, e, f, g, h, i, k, l});
    });
  });

  group('sort', () {
    test('edges', () {
      expect(() => graph.sortEdges(), throwsA(isA<UnsupportedError>()));
    });

    test('graph vertices', () {
      expect(() => graph.sort(), throwsA(isA<UnsupportedError>()));
    });
  });
}
