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
      graph.removeEdges(i, {k});
      expect(graph.edges(i), {l});
    });
    test('remove().', () {
      graph.remove(l);
      expect(graph.edges(i), <String>{});
      expect(graph.vertices.contains(l), false);
      // Restore graph:
      graph.addEdges(i, {l});
      expect(graph.vertices.contains(l), true);
      expect(graph.edges(i), {l});
    });
    test('addWeightedEdges(\'g\',{\'h\': 1}):', () {
      graph.addWeightedEdges('g', {'h': 1});
      expect(graph.edges('g'), {'h'});
      expect(graph.weightedGraphData['g']?['h'], 1);
      graph.removeEdges('g', {'h'});
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
    test('vertices().', () {
      expect(graph.vertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
  group('Topological ordering:', () {
    // test('stronglyConnectedComponents().', () {
    //   expect(graph.stronglyConnectedComponents, [
    //     [h],
    //     [b],
    //     [g],
    //     [c],
    //     [e],
    //     [a],
    //     {l},
    //     [i],
    //     [f],
    //     [d],
    //     {k}
    //   ]);
    // });
    // test('shortestPath().', () {
    //   expect(graph.shortestPath(d, l), [f, i, l]);
    // });

    test('isAcyclic(): self-loop.', () {
      graph.addEdges(l, {l});
      expect(
        graph.isAcyclic,
        false,
      );
      graph.removeEdges(l, {l});
    });
    test('isAcyclic(): without cycles', () {
      expect(graph.isAcyclic, true);
    });

    test('topologicalOrdering(): self-loop', () {
      graph.addEdges(l, {l});
      expect(graph.topologicalOrdering, null);
      graph.removeEdges(l, {l});
    });
    test('topologicalOrdering(): cycle', () {
      graph.addEdges(i, {k});
      expect(graph.topologicalOrdering, null);
      graph.removeEdges(i, {k});
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
  group('Cycles', () {
    test('graph.cycle | acyclic graph.', () {
      expect(graph.cycle, <String>[]);
    });

    test('graph.cycle | cyclic graph.', () {
      graph.addEdges(l, {l});
      expect(graph.cycle, [l, l]);
      graph.removeEdges(l, {l});
    });

    test('graph.cycle | non-trivial cycle.', () {
      graph.addEdges(i, {k});
      expect(graph.cycle, [f, i, k, f]);
      graph.removeEdges(i, {k});
    });
  });
  group('TransitiveClosure', () {
    test('acyclic graph', () {
      expect(
        WeightedDirectedGraph.transitiveClosure(graph).weightedGraphData,
        <String, Map<String, int>>{
          a: {b: 1, h: 7, c: 2, g: 6, e: 4},
          b: {h: 6},
          h: {},
          c: {h: 5, g: 4},
          g: {},
          e: {g: 2},
          d: {e: 1, g: 3, f: 2, i: 5, l: 5},
          f: {i: 3, l: 3},
          i: {l: 0},
          l: {},
          k: {g: 4, f: 5, i: 8, l: 8},
        },
      );
    });
    test('cyclic graph', () {});
  });
}
