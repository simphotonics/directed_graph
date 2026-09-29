import 'package:directed_graph/directed_graph.dart';

// // To run this program navigate to
// // the folder 'directed_graph/example'
// // in your terminal and type:
// //
// // # dart bin/example.dart
// //
// // followed by enter.
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
}
