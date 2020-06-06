import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

/// To run the test, navigate to the folder 'directed_graph'
/// in your local copy of this library and use the command:
///
/// # pub run test -r expanded --test-randomize-ordering-seed=random
///
void main() {
  int comparator(
    Vertex<String> vertex1,
    Vertex<String> vertex2,
  ) {
    return vertex1.data.compareTo(vertex2.data);
  }

  var a = Vertex<String>('a');
  var b = Vertex<String>('b');
  var c = Vertex<String>('c');
  var d = Vertex<String>('d');
  var e = Vertex<String>('e');
  var f = Vertex<String>('f');
  var g = Vertex<String>('g');
  var h = Vertex<String>('h');
  var i = Vertex<String>('i');
  var k = Vertex<String>('k');
  var l = Vertex<String>('l');

  final graph = DirectedGraph<String>(
    {
      a: [b, h, c, e],
      d: [e, f],
      b: [h],
      c: [h, g],
      f: [i],
      i: [l],
      k: [g, f]
    },
    comparator: comparator,
  );

  final cyclicGraph = DirectedGraph<String>.from(graph);
  cyclicGraph.addEdges(i, [k]);
  cyclicGraph.addEdges(l, [l]);

  final graphCrawler = GraphCrawler<String>(edges: graph.edges);
  final cyclicGraphCrawler = GraphCrawler<String>(edges: cyclicGraph.edges);

  group('Acyclic graph:', () {
    test('no path:', () {
      expect(graphCrawler.paths(a, l), []);
    });
    test('simple path:', () {
      expect(graphCrawler.paths(d, i), [
        [d, f, i]
      ]);
    });
    test('complex path:', () {
      expect(graphCrawler.paths(a, h), [
        [a, b, h],
        [a, h],
        [a, c, h],
      ]);
    });
  });
  group('Cyclic graph:', () {
    test('no path:', () {
      expect(cyclicGraphCrawler.paths(a, l), []);
    });
    test('simple path:', () {
      expect(cyclicGraphCrawler.paths(d, i), [
        [d, f, i]
      ]);
    });
    test('complex path:', () {
      expect(cyclicGraphCrawler.paths(a, h), [
        [a, b, h],
        [a, h],
        [a, c, h],
      ]);
    });

    test('cycle:', () {
      expect(cyclicGraphCrawler.paths(d, l), [
        [d, f, i, l],
      ]);
    });
    test('cycle:', () {
      expect(cyclicGraphCrawler.paths(f, f), [
        [f, i, k, f],
      ]);
    });

    test('trivial cycle:', () {
      expect(cyclicGraphCrawler.paths(l, l), [
        [l, l],
      ]);
    });
  });
}
