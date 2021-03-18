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

  group('Path', () {
    test('no path a -> l', () {
      expect(crawler.path(a, l), <List<String>>[]);
    });
    test('d -> i', () {
      expect(crawler.path(d, i), [d, f, i]);
    });
    test('a -> h:', () {
      expect(crawler.path(a, h), [a, h]);
    });
    test('cycle: d->l', () {
      expect(crawler.path(d, l), [d, f, i, l]);
    });
    test('cycle: f->f', () {
      expect(
        crawler.path(f, f),
        [f, i, k, f],
      );
    });
    test('trivial cycle: l->l:', () {
      expect(
        crawler.path(l, l),
        [l, l],
      );
    });
  });

  group('Paths:', () {
    test('no path a->l', () {
      expect(crawler.paths(a, l), <List<String>>[]);
    });
    test('d -> i', () {
      expect(crawler.paths(d, i), [
        [d, f, i]
      ]);
    });
    test('a -> h:', () {
      expect(
        crawler.paths(a, h),
        [
          [a, h],
          [a, b, h],
          [a, c, h],
        ],
      );
    });

    test(' d->l', () {
      expect(crawler.paths(d, l), [
        [d, f, i, l],
      ]);
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
    });
  });

  group('Tree:', () {
    test('Root: a with cycle', () {
      addTearDown(() {
        graph.removeEdges('a', {'a'});
      });
      graph.addEdges('a', {'a'});
      expect(crawler.tree('a'), [
        {'b'},
        {'h'},
        {'c'},
        {'e'},
        {'a'},
        {'b', 'h'},
        {'c', 'h'},
        {'c', 'g'},
      ]);
    });

    test('Root: a', () {
      expect(crawler.tree('a'), [
        {'b'},
        {'h'},
        {'c'},
        {'e'},
        {'b', 'h'},
        {'c', 'h'},
        {'c', 'g'}
      ]);
    });
    test('Root: a, target: h', () {
      expect(crawler.tree('a', 'h'), [
        {'b'},
        {'h'},
        {'c'},
        {'e'},
        {'b', 'h'},
        {'c', 'h'}
      ]);
    });
    test('Root: d', () {
      expect(crawler.tree('d'), [
        ['e'],
        ['f'],
        ['f', 'i'],
        ['f', 'i', 'l'],
        ['f', 'i', 'k'],
        ['f', 'i', 'k', 'g']
      ]);
    });
  });
  group('Mapped Tree:', () {
    test('mappedTree(a)', () {
      expect(crawler.mappedTree(a), {
        'b': [
          {'b'}
        ],
        'h': [
          {'h'},
          {'b', 'h'},
          {'c', 'h'}
        ],
        'c': [
          {'c'}
        ],
        'e': [
          {'e'}
        ],
        'g': [
          {'c', 'g'}
        ]
      });
    });
  });
}
