import 'package:directed_graph/directed_graph.dart';

void main(List<String> args) {
  int comparator(String s1, String s2) {
    return s1.compareTo(s2);
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

  int sum(int left, int right) => left + right;

  var graph = WeightedDirectedMultiGraph<String, int>(
    {
      a: {
        b: [1, 10],
        h: [7],
        c: [2, 200],
        e: [40],
        g: [7],
      },
      b: {
        h: [6],
      },
      c: {
        d: [1],
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
        k: [2],
      },
      k: {
        g: [4],
        f: [5],
      },
      l: {
        l: [0],
      },
    },
    summation: sum,
    zero: 0,
    comparator: comparator,
  );

  // graph.addEdge(c, d, 17);
  // graph.addEdge(c, d, 100);
  // graph.addEdge(c, d, 3);

  graph.addEdges(c, {
    d: [100, 17, 3],
    f: [71, 69, 45],
  });

  print('Weighted Graph:');
  print(graph);

  print('\nNeighbouring vertices sorted by weight:');
  final lightestPath = graph.lightestPath(a, g);
  print('\nLightest path a -> g');
  print('${lightestPath.vertices} weight: ${lightestPath.weight}');

  final heaviestPath = graph.heaviestPath(a, g);
  print('\nHeaviest path a -> g');
  print('${heaviestPath.vertices} weigth: ${heaviestPath.weight}');

  final shortestPath = graph.shortestPath(a, g);
  print('\nShortest path a -> g');
  print('$shortestPath weight: ${graph.weightAlong(shortestPath)}');

  print('\nVertices reachable from d:');
  print(graph.reachableVertices(d));

  print('\nRemoving vertices a->b (weight:10)');
  graph.removeEdge(a, b, 10);
  print(graph);

  print('\nRemoving vertices a-> c:[2, 200])');
  graph.removeEdges(a, {
    c: [2, 200],
    g: [7],
  });
  print(graph);

  print('---------------');
}
