import 'package:directed_graph/directed_graph.dart';
import 'package:directed_graph/graph_crawler.dart';

// To run this program navigate to
// the folder 'directed_graph/example'
// in your terminal and type:
//
// # dart bin/example.dart
//
// followed by enter.
void main() {
  var a = Vertex<String>('A');
  var b = Vertex<String>('B');
  var c = Vertex<String>('C');
  var d = Vertex<String>('D');

  var graph = DirectedGraph<String>({
    a: [b, c, d],
    b: [a, c],
    c: [a, b],
    d: []
  });

  // Create graph crawler.
  final crawler = GraphCrawler<String>(edges: graph.edges);

  print(crawler.path(c, d));


  
}
