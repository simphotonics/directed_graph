import 'package:directed_graph/directed_graph.dart';

void main(List<String> args) {
  int comparator(
    String s1,
    String s2,
  ) {
    return s1.compareTo(s2);
  }

  final a = 'a';
  final b = 'b';
  final c = 'c';
  final d = 'd';
  final e = 'e';
  final f = 'f';
  final g = 'g';
  final h = 'h';
  final i = 'i';
  final k = 'k';
  final l = 'l';

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
      l: {l: 0}
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
  print('$lightestPath weight: ${graph.weightAlong(lightestPath)}');

  final heaviestPath = graph.heaviestPath(a, g);
  print('\nHeaviest path a -> g');
  print('$heaviestPath weigth: ${graph.weightAlong(heaviestPath)}');

  final shortestPath = graph.shortestPath(a, g);
  print('\nShortest path a -> g');
  print('$shortestPath weight: ${graph.weightAlong(shortestPath)}');

  print('\nTransitive Closure');
  print(WeightedDirectedGraph.transitiveClosure(graph));

  print('\nTransitive Weighted Edges:');
  print(graph.transitiveWeightedEdges);

  print('\nVertices reachable from d:');
  print(graph.reachableVertices(d));
}
