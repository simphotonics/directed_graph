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

  group('Basic:', () {
    test('toString().', () {
      expect(
          graph.toString(),
          '{\n'
          ' \'a\': {\'b\', \'h\', \'c\', \'e\'},\n'
          ' \'b\': {\'h\'},\n'
          ' \'c\': {\'h\', \'g\'},\n'
          ' \'d\': {\'e\', \'f\'},\n'
          ' \'e\': {},\n'
          ' \'f\': {\'i\'},\n'
          ' \'g\': {},\n'
          ' \'h\': {},\n'
          ' \'i\': {\'l\'},\n'
          ' \'k\': {\'g\', \'f\'},\n'
          ' \'l\': {},\n'
          '}');
    });
    test('get comparator', () {
      expect(graph.comparator, comparator);
    });
    test('set comparator.', () {
      graph.comparator = inverseComparator;
      addTearDown(() {
        graph.comparator = comparator;
      });
      expect(graph.comparator, inverseComparator);
      expect(graph.sortedVertices, [l, k, i, h, g, f, e, d, c, b, a]);
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

  group('Manipulating edges/vertices.', () {
    test('addEdges():', () {
      addTearDown(() {
        graph.removeEdges(i, {k});
      });
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
      addTearDown(() {
        // Restore graph:
        graph.addEdges(i, {l});
      });
      graph.remove(l);
      expect(graph.edges(i), <String>{});
      expect(
        graph.sortedVertices,
        ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'],
      );
    });
    test('clear', () {
      final graphCopy = DirectedGraph.of(graph);
      expect(graphCopy.sortedVertices, graph.sortedVertices);
      graphCopy.clear();
      expect(graphCopy.isEmpty, true);
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
          {a: 4, b: 1, c: 2, d: 2, e: 0, f: 1, g: 0, h: 0, i: 1, k: 2, l: 0});
    });
    test('inDegreeMap.', () {
      expect(graph.inDegreeMap,
          {a: 0, b: 1, h: 3, c: 1, e: 2, d: 0, f: 2, g: 2, i: 1, l: 1, k: 0});
    });
    test('sortedVertices.', () {
      expect(graph.sortedVertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
  group('Graph topology:', () {
    test('stronglyConnectedComponents().', () {
      expect(graph.stronglyConnectedComponents, [
        [h],
        [b],
        [g],
        [c],
        [e],
        [a],
        {l},
        [i],
        [f],
        [d],
        {k}
      ]);
    });
    test('shortestPath().', () {
      expect(graph.shortestPath(d, l), [d, f, i, l]);
    });

    test('isAcyclic(): self-loop.', () {
      addTearDown(() {
        graph.removeEdges(l, {l});
      });
      graph.addEdges(l, {l});
      expect(
        graph.isAcyclic,
        false,
      );
    });
    test('isAcyclic(): without cycles', () {
      expect(graph.isAcyclic, true);
    });

    test('topologicalOrdering(): self-loop', () {
      addTearDown(() {
        graph.removeEdges(l, {l});
      });
      graph.addEdges(l, {l});
      expect(graph.topologicalOrdering, null);
    });
    test('topologicalOrdering(): cycle', () {
      addTearDown(() {
        graph.removeEdges(i, {k});
      });
      graph.addEdges(i, {k});
      expect(graph.topologicalOrdering, null);
    });
    test('sortedTopologicalOrdering():', () {
      expect(
          graph.sortedTopologicalOrdering, {a, b, c, d, e, h, k, f, g, i, l});
    });
    test('topologicalOrdering():', () {
      expect(graph.topologicalOrdering, {a, b, c, d, e, h, k, f, i, g, l});
    });
    test('topologicalOrdering(): empty graph', () {
      expect(DirectedGraph<int>({}).topologicalOrdering, <int>{});
    });
    test('localSources().', () {
      expect(graph.localSources, [
        [a, d, k],
        [b, c, e, f],
        [g, h, i],
        [l]
      ]);
    });
  });
  group('Cycles', () {
    test('graph.cycle | acyclic graph.', () {
      expect(graph.cycle, <String>[]);
    });

    test('graph.cycle | cyclic graph.', () {
      addTearDown(() {
        graph.removeEdges(l, {l});
      });
      graph.addEdges(l, {l});
      expect(graph.cycle, [l, l]);
    });

    test('graph.cycle | non-trivial cycle.', () {
      addTearDown(() {
        graph.removeEdges(i, {k});
      });
      graph.addEdges(i, {k});
      expect(graph.cycle, [f, i, k, f]);
    });
  });
  group('TransitiveClosure', () {
    test('acyclic graph', () {
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
}
