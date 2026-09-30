import 'package:directed_graph/directed_graph.dart';

void main(List<String> args) {
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

  int comparator(String s1, String s2) {
    return s1.compareTo(s2);
  }

  int sum(int left, int right) => left + right;

  var graph = WeightedDirectedGraph<String, int>(
    {
      a: {b: 1, h: 7, c: 2, e: 40, g: 7},
      b: {h: 6},
      c: {h: 5, g: 4},
      d: {e: 1, f: 2},
      e: {g: 2},
      f: {i: 3},
      i: {l: 3, k: 2},
      k: {g: 4, f: 5},
      l: {l: 0},
    },
    summation: sum,
    zero: 0,
    comparator: comparator,
  );

  print('Weighted Graph:');
  print(graph);

  print('\nNeighbouring vertices sorted by weight:');
  print(graph..sortEdgesByWeight());

  final lightestPath = graph.lightestPath(a, g);
  print('\nLightest path a -> g');
  print('${lightestPath.vertices} weight: ${lightestPath.weight}');

  final heaviestPath = graph.heaviestPath(a, g);
  print('\nHeaviest path a -> g');
  print('${heaviestPath.vertices} weigth: ${heaviestPath.weight}');

  final shortestPath = graph.shortestPath(a, g);
  print('\nShortest path a -> g');
  print('$shortestPath weight: ${graph.weightAlong(shortestPath)}');

  print('\nTransitive Closure');
  print(WeightedDirectedGraph.transitiveClosure(graph));

  print('\nVertices reachable from d:');
  print(graph.reachableVertices(d));

  print('\nUpdate weight of edge (a,b) with value 101:');
  graph.updateEdgeWeight(vertex: a, connectedVertex: b, weight: 101);
  print('graph.weightedEdges(a): ${graph.weightedEdges(a)}');
}
