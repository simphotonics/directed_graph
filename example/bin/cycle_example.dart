import 'package:directed_graph/directed_graph.dart';

// // To run this program navigate to
// // the folder 'directed_graph/example'
// // in your terminal and type:
// //
// // # dart bin/example.dart
// //
// // followed by enter.
void main() {
  var graph = DirectedGraph<String>({
    'a': {'b', 'c', 'd'},
    'b': {'a', 'c', 'd'},
    'c': {'a', 'b', 'd'},
    'd': {'a', 'b', 'c'},
  });
  print(graph.inDegreeMap);
  print(graph.outDegreeMap);
  print(graph);
  print(graph.localSources);
  print(graph.cycle);
}
