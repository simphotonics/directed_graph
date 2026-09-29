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
  final graph0 = DirectedMultiGraph<String>({
    a: {b: 1, h: 4, c: 3, e: 2},
    d: {e: 1, f: 4},
    b: {h: 1},
    c: {h: 2, g: 3},
    f: {i: 2},
    i: {l: 1},
    k: {g: 1, f: 1},
  }, comparator: comparator);

  group('Basic:', () {
    test('toString().', () {
      final graph = DirectedMultiGraph.of(graph0);
      expect(
        graph.toString(),
        '{\n'
        ' \'a\': {\'b\': 1, \'h\': 4, \'c\': 3, \'e\': 2},\n'
        ' \'b\': {\'h\': 1},\n'
        ' \'c\': {\'h\': 2, \'g\': 3},\n'
        ' \'d\': {\'e\': 1, \'f\': 4},\n'
        ' \'e\': {},\n'
        ' \'f\': {\'i\': 2},\n'
        ' \'g\': {},\n'
        ' \'h\': {},\n'
        ' \'i\': {\'l\': 1},\n'
        ' \'k\': {\'g\': 1, \'f\': 1},\n'
        ' \'l\': {},\n'
        '}',
      );
    });
    test('get comparator', () {
      expect(graph0.comparator, comparator);
    });
    test('default comparator', () {
      final graph = DirectedMultiGraph<num>.empty();
      expect(graph.comparator, isA<Comparator<num>>());
    });
    test('null comparator', () {
      final graph = DirectedMultiGraph<num>.empty()..comparator = null;
      expect(graph.comparator, equals(null));
    });

    test('set comparator.', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.comparator = inverseComparator;
      expect(graph.comparator, inverseComparator);
      expect(graph.sortedVertices.toList(), [l, k, i, h, g, f, e, d, c, b, a]);
    });
    test('for loop.', () {
      var index = 0;
      final graph = DirectedMultiGraph.of(graph0);
      final vertices = graph.vertices.toList();
      for (var vertex in graph) {
        expect(vertex, vertices[index]);
        ++index;
      }
    });
  });

  group('Manipulating edges/vertices:', () {
    test('addEdge', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdge(i, k);
      expect(graph.edges(i), {l, k});
    });

    test('addEdges', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdges(i, [k]);
      expect(graph.edges(i), {l, k});
    });
    test('removeEdge', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.removeEdge(a, b);
      expect(graph.edges(a), {h, c, e});
    });
    test('removeEdges', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.removeEdges(a, [b, h, c]);
      expect(graph.edges(a), {h, c, e});
    });

    test('remove(l)', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.remove(l);
      expect(graph.edges(i), <String>{});
      expect(graph.sortedVertices.toList(), [a, b, c, d, e, f, g, h, i, k]);
    });
    test('clear', () {
      final graph = DirectedMultiGraph.of(graph0);
      expect(graph.sortedVertices, graph0.sortedVertices);
      graph.clear();
      expect(graph.isEmpty, true);
    });
    test('clearEdges', () {
      final graph = DirectedMultiGraph.of(graph0);
      expect(graph.sortedVertices, graph0.sortedVertices);
      graph.clearEdges();
      expect(graph.sortedVertices, graph0.sortedVertices);
      for (var vertex in graph.sortedVertices) {
        expect(graph.edges(vertex), isEmpty);
      }
    });
  });
  group('Graph data:', () {
    final graph = DirectedMultiGraph.of(graph0);
    test('edges().', () {
      expect(graph.edges(a), {b, h, c, e});
    });
    test('indegree().', () {
      expect(graph.inDegree(h), 3);
    });
    test('indegree vertex with self-loop.', () {
      addTearDown(() {
        graph.removeEdges(l, [l]);
      });
      graph.addEdges(l, [l]);
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
      final graph = DirectedMultiGraph<String>({
        k: {a: 1},
        a: {},
        b: {c: 2},
        c: {b: 2},
      });
      expect(graph.stronglyConnectedComponents(), [
        {a},
        {k},
        {c, b},
      ]);
    });
    test('stronglyConnectedComponents(sorted: true).', () {
      final graph = DirectedMultiGraph<String>({
        k: {a: 1},
        a: {},
        b: {c: 2},
        c: {b: 2},
      });
      expect(graph.stronglyConnectedComponents(sorted: true), [
        {a},
        {b, c},
        {k},
      ]);
    });

    test('stronglyConnectedComponents(sorted: true, '
        'comparator: inverseComparator).', () {
      final graph = DirectedMultiGraph<String>({
        k: {a: 1},
        a: {},
        b: {c: 2},
        c: {b: 2},
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
      final graph = DirectedMultiGraph.of(graph0);
      expect(graph.shortestPath(d, l), [d, f, i, l]);
    });

    test('isAcyclic(): self-loop.', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdges(l, [l]);
      expect(graph.isAcyclic, false);
    });
    test('isAcyclic(): without cycles', () {
      final graph = DirectedMultiGraph.of(graph0);
      expect(graph.isAcyclic, true);
    });

    test('topologicalOrdering(): self-loop', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdges(l, [l]);
      expect(graph.topologicalOrdering(), null);
    });
    test('topologicalOrdering(): cycle', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdges(i, [k]);
      expect(graph.topologicalOrdering(), null);
    });
    test('topologicalOrdering():', () {
      final graph = DirectedMultiGraph<String>({
        k: {b: 1, a: 1, c: 2},
        d: {},
        e: {},
      });
      expect(graph.topologicalOrdering()?.toList(), [d, e, k, c, a, b]);
    });
    test('topologicalOrdering(sorted: true):', () {
      final graph = DirectedMultiGraph<String>({
        k: {b: 1, a: 1, c: 2},
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
      final graph = DirectedMultiGraph<String>({
        k: {b: 1, a: 1, c: 2},
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
      expect(DirectedMultiGraph<int>({}).topologicalOrdering(), <int>{});
    });

    test('reverseTopologicalOrdering():', () {
      final graph = DirectedMultiGraph<String>({
        k: {b: 1, a: 1, c: 2},
        d: {},
        e: {},
      });
      expect(graph.reverseTopologicalOrdering()?.toList(), [b, a, c, k, e, d]);
    });
    test('reverseTopologicalOrdering(sorted: true):', () {
      final graph = DirectedMultiGraph<String>({
        k: {b: 1, a: 1, c: 2},
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
      final graph = DirectedMultiGraph<String>({
        k: {b: 1, a: 1, c: 2},
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
      final graph = DirectedMultiGraph.of(graph0);
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
      final graph = DirectedMultiGraph.of(graph0);
      expect(graph.cycle(), <String>[]);
    });

    test('graph.cycle | cyclic graph.', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdges(l, [l]);
      expect(graph.cycle(), [l, l]);
    });

    test('graph.cycle | non-trivial cycle.', () {
      final graph = DirectedMultiGraph.of(graph0);
      graph.addEdges(i, [k]);
      expect(graph.cycle(), [f, i, k, f]);
    });
  });
  group('TransitiveClosure', () {
    test('acyclic graph', () {
      final graph = DirectedMultiGraph.of(graph0);
      expect(DirectedMultiGraph.transitiveClosure(graph).data, {
        'a': {'b': 1, 'h': 4, 'c': 3, 'g': 1, 'e': 2},
        'b': {'h': 1},
        'c': {'h': 2, 'g': 3},
        'd': {'e': 1, 'f': 4, 'i': 1, 'l': 1},
        'e': {},
        'f': {'i': 2, 'l': 1},
        'g': {},
        'h': {},
        'i': {'l': 1},
        'k': {'g': 1, 'f': 1, 'i': 1, 'l': 1},
        'l': {},
      });
    });
  });
  group('Default comparator', () {
    // Original graph
    final graph = DirectedMultiGraph<String>({
      b: {h: 1},
      c: {h: 2, g: 3},
      k: {g: 1, f: 1},
      a: {b: 1, h: 4, c: 3, e: 2},
      f: {i: 2},
      d: {e: 1, f: 4},
      i: {l: 1},
    }, comparator: comparator);

    test('sort Strings', () {
      for (var vertex in graph.sortedVertices) {
        vertex = '${vertex}1';
      }
      expect(graph.sortedVertices, {a, b, c, d, e, f, g, h, i, k, l});
    });
  });

  group('sort', () {
    test('edges', () {
      final graph = DirectedMultiGraph.of(graph0)..sortEdges();
      expect(graph0.edges(a), [b, h, c, e]);
      expect(graph.edges(a), [b, c, e, h]);
    });

    test('graph vertices', () {
      final graph = DirectedMultiGraph.of(graph0)..sort();
      expect(graph0.vertices, [a, b, h, c, e, d, f, g, i, l, k]);
      expect(graph.vertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
}
