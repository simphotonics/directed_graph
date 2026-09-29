import 'package:directed_graph/directed_graph.dart';

void main() {
  int comparator(String s1, String s2) => s1.compareTo(s2);
  //int inverseComparator(String s1, String s2) => -comparator(s1, s2);

  // Constructing a graph from vertices.
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

  final graph = DirectedMultiGraph<String>({
    a: {b: 1, h: 4, c: 2, e: 1},
    b: {h: 2},
    d: {e: 1, f: 1},
    c: {h: 1, g: 2},
    e: {g: -1},
    f: {i: 2},
    i: {l: 3},
    k: {g: 1, f: 3},
  }, comparator: comparator);

  print('Example Multi-Directed Graph ...');
  print('graph.toString()');
  print(graph);

  print('\nAdding edges: a -> [a, b, b, c, c, c]');
  graph.addEdges(a, [a, b, b, c, c, c]);
  print(graph);

  print('\nSorting edges');
  graph.sortEdges();
  print(graph);
}
