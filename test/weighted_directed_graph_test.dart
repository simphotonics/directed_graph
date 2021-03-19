import 'package:test/test.dart';

import 'package:directed_graph/directed_graph.dart';

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

  int sum(int left, int right) => left + right;

  var graph = WeightedDirectedGraph<String, int>(
    {
      'a': {'b': 1, 'h': 7, 'c': 2, 'e': 4},
      'b': {'h': 6},
      'c': {'h': 5, 'g': 4},
      'd': {'e': 1, 'f': 2},
      'e': {'g': 2},
      'f': {'i': 3},
      'i': {'l': 3},
      'k': {'g': 4, 'f': 5},
    },
    summation: sum,
    zero: 0,
    comparator: comparator,
  );

  group('Basic:', () {
    test('toString().', () {
      expect(
          graph.toString(),
          '{\n'
          ' \'a\': {\'b\': 1, \'h\': 7, \'c\': 2, \'e\': 4},\n'
          ' \'b\': {\'h\': 6},\n'
          ' \'c\': {\'h\': 5, \'g\': 4},\n'
          ' \'d\': {\'e\': 1, \'f\': 2},\n'
          ' \'e\': {\'g\': 2},\n'
          ' \'f\': {\'i\': 3},\n'
          ' \'g\': {},\n'
          ' \'h\': {},\n'
          ' \'i\': {\'l\': 3},\n'
          ' \'k\': {\'g\': 4, \'f\': 5},\n'
          ' \'l\': {},\n'
          '}');
    });
    test('get comparator', () {
      expect(graph.comparator, comparator);
    });
    test('set comparator.', () {
      addTearDown(() {
        graph.comparator = comparator;
      });
      graph.comparator = inverseComparator;
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

  group('Manipulating edges/vertices:', () {
    test('remove/add vertex l.', () {
      addTearDown(() {
        graph.addEdges(i, <String, int>{l: 3});
      });
      graph.remove(l);
      expect(graph.edges(i), <String>{});
      expect(graph.vertices.contains(l), false);
      // Restore graph:
    });
    test('addEdges(\'g\',{\'h\': 1}):', () {
      addTearDown(() {
        graph.removeEdges('g', {'h'});
      });
      graph.addEdges('g', {'h': 1});
      expect(graph.edges('g'), {'h'});
      expect(graph.data['g']?['h'], 1);
    });
    test('clear', () {
      final graphCopy = WeightedDirectedGraph.of(graph);
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
      graph.addEdges(l, {l: 0});
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
        e: 1,
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
        g: 3,
        d: 0,
        f: 2,
        i: 1,
        l: 1,
        k: 0,
      });
    });
    test('sortedVertices().', () {
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
      graph.addEdges(l, {l: 0});
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
      graph.addEdges(l, {l: 0});
      expect(graph.topologicalOrdering, null);
    });
    test('topologicalOrdering(): cycle', () {
      addTearDown(() {
        graph.removeEdges(i, {k});
      });
      graph.addEdges(i, {k: 2});
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
      expect(
          WeightedDirectedGraph<String, int>(
            {},
            zero: 0,
            summation: sum,
          ).topologicalOrdering,
          <String>{});
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

  group('Weigth:', () {
    test('graph weigth', () {
      expect(graph.weight, 49);
    });
    test('weightAlong([a, c, g])', () {
      expect(graph.weightAlong([a, c, g]), 6);
    });
  });

  group('TransitiveClosure', () {
    test('acyclic graph', () {
      expect(
        WeightedDirectedGraph.transitiveClosure(graph).data,
        <String, Map<String, int>>{
          'a': {'b': 1, 'h': 7, 'c': 2, 'g': 6, 'e': 4},
          'b': {'h': 6},
          'c': {'h': 5, 'g': 4},
          'd': {'e': 1, 'g': 3, 'f': 2, 'i': 5, 'l': 8},
          'e': {'g': 2},
          'f': {'i': 3, 'l': 6},
          'g': {},
          'h': {},
          'i': {'l': 3},
          'k': {'g': 4, 'f': 5, 'i': 8, 'l': 11},
          'l': {}
        },
      );
    });
  });

  group('path:', () {
    test('min. weight', () {
      expect(graph.lightestPath('a', 'g'), [a, c, g]);
      expect(graph.weightAlong([a, c, g]), 6);
    });
    test('max. weight', () {
      addTearDown(() {
        graph.removeEdges(h, {g});
      });
      graph.addEdges(h, {g: 17});
      expect(graph.heaviestPath(a, g), [a, h, g]);
      expect(graph.weightAlong([a, h, g]), 24);
    });
  });
}
