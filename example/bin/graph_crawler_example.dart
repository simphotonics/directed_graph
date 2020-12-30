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
      a: {a: 0, b: 1, h: 7, c: 2, e: 40},
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
  print('Graph:');
  print(graph);

  final path = graph.optimalPath(a, g, extremum: Extremum.max);
  final lightestPath = graph.lightestPath(a, g);
  final heaviestPath = graph.heaviestPath(a, g);
  
  print('Optimal path: $path');
  print('Lightest path: $lightestPath');
  print('Heaviest path: $heaviestPath');
  print('Cycle: ${graph.cycle}');

  final crawler = GraphCrawler<String>(graph.edges);

  final treeMap = crawler.mappedTree('d');

  print(treeMap);
}
