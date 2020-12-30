import 'package:directed_graph/directed_graph.dart';
import 'package:directed_graph/src/utils/color_utils.dart';

void main(List<String> args) {
  int comparator(String s1, String s2) => s1.compareTo(s2);
  int inverseComparator(String s1, String s2) => -comparator(s1, s2);

  // Constructing a graph from vertices.
  final graph = DirectedGraph<String>(
    {
      'a': {'b', 'c'},
      'b': {'c'},
      'c': {'d', 'f'},
      'd': {'e', 'f'},
      'e': {'c','f'},

    },
    comparator: inverseComparator,
  );

  print(blue('Directed graph'));
  print(graph);

  print(blue('Strongly connected components'));
  print(graph.stronglyConnectedComponents);
}
