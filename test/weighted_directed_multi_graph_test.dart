import 'package:test/test.dart';

import 'package:directed_graph/directed_graph.dart';

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
  const zero = 0;

  int sum(int left, int right) => left + right;

  final graph0 = WeightedDirectedMultiGraph<String, int>(
    {
      a: {
        b: [1, 2],
        h: [7],
        c: [2],
        e: [4],
      },
      b: {
        h: [6],
      },
      c: {
        h: [5],
        g: [4],
      },
      d: {
        e: [1],
        f: [2],
      },
      e: {
        g: [2],
      },
      f: {
        i: [3],
      },
      i: {
        l: [3],
      },
      k: {
        g: [4],
        f: [5],
      },
    },
    summation: sum,
    zero: zero,
    comparator: comparator,
  );

  group('Basic:', () {
    test('toString().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(
        graph.toString(),
        '{\n'
        ' \'a\': {\'b\': [1, 2], \'h\': [7], \'c\': [2], \'e\': [4]},\n'
        ' \'b\': {\'h\': [6]},\n'
        ' \'c\': {\'h\': [5], \'g\': [4]},\n'
        ' \'d\': {\'e\': [1], \'f\': [2]},\n'
        ' \'e\': {\'g\': [2]},\n'
        ' \'f\': {\'i\': [3]},\n'
        ' \'g\': {},\n'
        ' \'h\': {},\n'
        ' \'i\': {\'l\': [3]},\n'
        ' \'k\': {\'g\': [4], \'f\': [5]},\n'
        ' \'l\': {},\n'
        '}',
      );
    });
    test('get comparator', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.comparator, comparator);
    });
    test('set comparator.', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.comparator = inverseComparator;
      expect(graph.comparator, inverseComparator);
      expect(graph.sortedVertices, [l, k, i, h, g, f, e, d, c, b, a]);
    });
    test('for loop.', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
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
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.remove(l);
      expect(graph.edges(i), <String>{});
      expect(graph.vertices.contains(l), false);
      // Restore graph:
    });
    test('addEdge', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdge(g, h, 1);
      expect(graph.edges(g), {h});
      expect(graph.weightAlong([g, h]), 1);
    });

    test('addEdges(\'g\',{\'h\': 1}):', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdges(g, {
        h: [1],
      });
      expect(graph.edges(g), {h});
      expect(graph.weightAlong([g, h]), 1);
    });
    test('removeEdge', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.removeEdge(a, b, 2);
      expect(graph.edges(a), {b, h, c, e});
    });
    test('removeEdges', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.removeEdges(a, {
        b: [1, 2],
        h: [7],
        c: [2],
      });
      expect(graph.edges(a), {e});
    });

    test('clear', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.sortedVertices, graph0.sortedVertices);
      graph.clear();
      expect(graph.isEmpty, true);
    });
    test('clearEdges', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.sortedVertices, graph0.sortedVertices);
      graph.clearEdges();
      expect(graph.sortedVertices, graph0.sortedVertices);
      for (var vertex in graph.sortedVertices) {
        expect(graph.edges(vertex), isEmpty);
      }
    });
  });
  group('Graph data:', () {
    test('edges().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.edges(a), {b, h, c, e});
    });
    test('indegree().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.inDegree(h), 3);
    });
    test('indegree vertex with self-loop.', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdges(l, {
        l: [0],
      });
      expect(graph.inDegree(l), 2);
    });
    test('outDegree().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.outDegree(d), 2);
    });
    test('outDegreeMap().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
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
      final graph = WeightedDirectedMultiGraph.of(graph0);
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
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.sortedVertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
  group('Graph topology:', () {
    test('stronglyConnectedComponents().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.stronglyConnectedComponents(), [
        [h],
        [b],
        [g],
        [c],
        [e],
        [a],
        [l],
        [i],
        [f],
        [d],
        [k],
      ]);
    });
    test('shortestPath().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.shortestPath(d, l), [d, f, i, l]);
    });

    test('isAcyclic(): self-loop.', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdges(l, {
        l: [0],
      });
      expect(graph.isAcyclic, false);
    });
    test('isAcyclic(): without cycles', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.isAcyclic, true);
    });

    test('topologicalOrdering(): self-loop', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdges(l, {
        l: [0],
      });
      expect(graph.topologicalOrdering(), null);
    });
    test('topologicalOrdering(): cycle', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdges(i, {
        k: [2],
      });
      expect(graph.topologicalOrdering(), null);
    });

    test('topologicalOrdering({sorted: false}):', () {
      final graph = WeightedDirectedMultiGraph(
        {
          k: {
            b: [2],
            c: [3],
            a: [4],
          },
          d: <String, List<int>>{},
        },
        summation: sum,
        zero: zero,
        comparator: comparator,
      );
      expect(graph.topologicalOrdering(sorted: false)?.toList(), [
        d,
        k,
        a,
        c,
        b,
      ]);
    });
    test('topologicalOrdering({sorted: true}):', () {
      final graph = WeightedDirectedMultiGraph(
        {
          k: {
            b: [2],
            c: [3],
            a: [4],
          },
          d: <String, List<int>>{},
        },
        summation: sum,
        zero: zero,
        comparator: comparator,
      );
      expect(graph.topologicalOrdering(sorted: true)?.toList(), [
        d,
        k,
        a,
        b,
        c,
      ]);
    });

    test('topologicalOrdering():', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.topologicalOrdering(), {a, b, c, d, e, h, k, f, i, g, l});
    });
    test('topologicalOrdering(): empty graph', () {
      expect(
        WeightedDirectedMultiGraph<String, int>(
          {},
          zero: 0,
          summation: sum,
        ).topologicalOrdering(),
        <String>{},
      );
    });
    test('localSources().', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.localSources(), [
        [a, d, k],
        [b, c, e, f],
        [g, h, i],
        [l],
      ]);
    });
  });

  group('Weigth:', () {
    test('graph weigth', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(graph.weight, 51);
    });
    test('weightAlong([a, c, g])', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      expect(
        graph.weightAlong([a, c, g], selector: EdgeSelector.lowestWeight),
        6,
      );
    });
  });

  group('path:', () {
    test('min. weight', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      final lightestPath = graph.lightestPath(a, g);
      expect(lightestPath.vertices, [a, c, g]);
      expect(graph.weightAlong([a, c, g]), lightestPath.weight);
    });
    test('max. weight', () {
      final graph = WeightedDirectedMultiGraph.of(graph0);
      graph.addEdges(h, {
        g: [17],
      });
      final heaviestPath = graph.heaviestPath(a, g);
      expect(heaviestPath.vertices, [a, b, h, g]);
      expect(
        graph.weightAlong([a, b, h, g], selector: EdgeSelector.highestWeight),
        heaviestPath.weight,
      );
    });
  });

  group('Default comparator', () {
    final graph = WeightedDirectedMultiGraph<String, int>(
      {
        a: {
          b: [1],
          h: [7],
          c: [2],
          e: [4],
        },
        b: {
          h: [6],
        },
        c: {
          h: [5],
          g: [4],
        },
        d: {
          e: [1],
          f: [2],
        },
        e: {
          g: [2],
        },
        f: {
          i: [3],
        },
        i: {
          l: [3],
        },
        k: {
          g: [4],
          f: [5],
        },
      },
      summation: sum,
      zero: 0,
    );
    test('sort Strings', () {
      for (var vertex in graph.sortedVertices) {
        vertex = '${vertex}1';
      }
      expect(graph.sortedVertices, {a, b, c, d, e, f, g, h, i, k, l});
    });
  });
  group('sort:', () {
    final graph1 = WeightedDirectedMultiGraph<String, int>(
      {
        b: {
          h: [6],
        },
        a: {
          b: [1],
          h: [7],
          c: [2],
          e: [4],
        },
        c: {
          h: [5],
          g: [4],
        },
        e: {
          g: [2],
        },
        d: {
          e: [1],
          f: [2],
        },
        f: {
          i: [3],
        },
        i: {
          l: [3],
        },
        k: {
          g: [4],
          f: [5],
        },
      },
      summation: sum,
      zero: zero,
      comparator: comparator,
    );
    test('edges', () {
      final graph = WeightedDirectedMultiGraph.of(graph1)..sortEdges();
      expect(graph1.edges(a), [b, h, c, e]);
      expect(graph.edges(a), [b, c, e, h]);
    });

    test('graph vertices', () {
      final graph = WeightedDirectedMultiGraph.of(graph1)..sort();
      expect(graph1.vertices, [b, h, a, c, e, g, d, f, i, l, k]);
      expect(graph.vertices, [a, b, c, d, e, f, g, h, i, k, l]);
    });
  });
}
