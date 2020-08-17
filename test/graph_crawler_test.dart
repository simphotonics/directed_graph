import 'package:directed_graph/directed_graph.dart';
import 'package:directed_graph/graph_crawler.dart';
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
      b: [h],
      c: [h, g],
      d: [e, f],
      e: [g],
      f: [i],
      i: [k, l],
      k: [g, f],
      l: [l]
    },
    comparator: comparator,
  );

  final crawler = GraphCrawler<String>(edges: graph.edges);

  group('Simple paths:', () {
    test('no path: a->l', () {
      expect(crawler.paths(a, l), []);
      expect(crawler.path(a, l), []);
    });
    test('d->i', () {
      expect(crawler.paths(d, i), [
        [d, f, i]
      ]);
      expect(crawler.path(d, i), [d, f, i]);
    });
    test('a->h:', () {
      expect(crawler.paths(a, h), [
        [a, b, h],
        [a, h],
        [a, c, h],
      ]);
      expect(crawler.path(a, h), [a, b, h]);
    });
  });
  group('Cyclic paths:', () {
    test('simple path: d->i', () {
      expect(crawler.paths(d, i), [
        [d, f, i]
      ]);
      expect(crawler.path(d, i), [d, f, i]);
    });
    test('cycle: d->l', () {
      expect(crawler.paths(d, l), [
        [d, f, i, l],
      ]);
      expect(crawler.path(d, l), [d, f, i, l]);
    });
    test('cycle: f->f', () {
      expect(crawler.paths(f, f), [
        [f, i, k, f],
      ]);
      expect(
        crawler.path(f, f),
        [f, i, k, f],
      );
    });

    test('trivial cycle: l->l:', () {
      expect(crawler.paths(l, l), [
        [l, l],
      ]);
      expect(
        crawler.path(l, l),
        [l, l],
      );
    });
  });
}
