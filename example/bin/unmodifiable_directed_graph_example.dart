import 'package:directed_graph/directed_graph.dart';

void main() {
  int comparator(String s1, String s2) => s1.compareTo(s2);

  // Constructing a graph from vertices.
  final graph = UnmodifiableDirectedGraph<String>({
    'a': {'b', 'h', 'c', 'e'},
    'b': {'h'},
    'c': {'h', 'g'},
    'd': {'e', 'f'},
    'e': {'g'},
    'f': {'i'},
    //g': {'a'},
    'i': {'l'},
    'k': {'g', 'f'},
  }, comparator: comparator);

  print(graph);
  // Throws an UnsupportedOperation error.
  graph.clear();
}
