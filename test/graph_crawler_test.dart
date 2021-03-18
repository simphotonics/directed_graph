import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

/// To run the test, navigate to the folder 'directed_graph'
/// in your local copy of this library and use the command:
///
/// # pub run test -r expanded --test-randomize-ordering-seed=random
///
void main() {
  int comparator(
    String s1,
    String s2,
  ) {
    return s1.compareTo(s2);
  }

  var a = 'a';
  var b = 'b';
  var c = 'c';
  var d = 'd';
  var e = 'e';
  var f = 'f';
  var g = 'g';
  var h = 'h';
  var i = 'i';
  var k = 'k';
  var l = 'l';

  var graph = DirectedGraph<String>(
    {
      a: {b, h, c, e},
      d: {e, f},
      b: {h},
      c: {h, g},
      f: {i},
      i: {l, k},
      k: {g, f},
      l: {l}
    },
    comparator: comparator,
  );

  final crawler = GraphCrawler<String>(graph.edges);

  group('Simple paths:', () {
    test('no path: a->l', () {
      expect(crawler.paths(a, l), <List<String>>[]);
      expect(crawler.path(a, l), <String>[]);
    });
    test('d->i', () {
      expect(crawler.paths(d, i), [
        [d, f, i]
      ]);
      expect(crawler.path(d, i), [d, f, i]);
    });
    test('a->h:', () {
      expect(
        crawler.paths(a, h),
        [
          [a, h],
          [a, b, h],
          [a, c, h],
        ],
      );
      expect(crawler.path(a, h), [a, h]);
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
  group('SimpleTree', () {
    test('Root: a', () {
      graph.addEdges('a', {'a'});
      expect(crawler.simpleTree('a'), [
        {'b'},
        {'h'},
        {'c'},
        {'e'},
        {'a'},
        {'b', 'h'},
        {'c', 'h'},
        {'c', 'g'},
      ]);
      graph.removeEdges('a', {'a'});
    });
  });
  group('Tree:', () {
    test('Root: a', () {
      expect(crawler.tree('a'), [
        ['a'],
        ['a', 'b'],
        ['a', 'h'],
        ['a', 'c'],
        ['a', 'e'],
        ['a', 'b', 'h'],
        ['a', 'c', 'h'],
        ['a', 'c', 'g'],
      ]);
    });
    test('Root: a, target: h', () {
      expect(crawler.tree('a', target: 'h'), [
        ['a'],
        ['a', 'b'],
        ['a', 'h'],
      ]);
    });
    test('Root: d, maxCount: 2', () {
      expect(crawler.tree('d', maxCount: 2), [
        [d],
        [d, e],
        [d, f],
        [d, f, i],
        [d, f, i, l],
        [d, f, i, k],
        [d, f, i, l, l],
        [d, f, i, k, g],
        [d, f, i, k, f],
        [d, f, i, k, f, i],
        [d, f, i, k, f, i, l],
        [d, f, i, k, f, i, k],
        [d, f, i, k, f, i, l, l],
        [d, f, i, k, f, i, k, g],
      ]);
    });
  });
  group('Mapped Tree:', () {
    test('mappedTree(a)', () {
      expect(crawler.mappedTree(a), {
        a: [<String>{}],
        b: [
          {b}
        ],
        h: [
          {h},
          {b, h},
          {c, h}
        ],
        c: [
          {c}
        ],
        e: [
          {e}
        ],
        g: [
          {c, g}
        ]
      });
    });
  });
}
