import 'package:directed_graph/directed_graph.dart';

void main() {
  const a = 'a';
  const b = 'b';
  const c = 'c';
  const d = 'd';

  var graph = DirectedGraph<String>({
    a: {b, c, d},
    b: {a, c, d},
    c: {a, b, d},
    d: {a, b, c},
  });
  print('inDegreeMap: ${graph.inDegreeMap}\n');

  print('outDegreeMap: ${graph.outDegreeMap}\n');

  print('Graph: $graph\n');

  print('Cycle: ${graph.cycle()}');

  print(graph.crawler.mappedTree(a));

  print(graph.crawler.shortestPaths(a));

  print(graph.paths(a, a));
}
