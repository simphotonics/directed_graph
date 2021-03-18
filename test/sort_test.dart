import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

void main() {
  int comparator(
    String s1,
    String s2,
  ) {
    return -s1.compareTo(s2);
  }

  var a = 'a';
  var b = 'b';
  var c = 'c';

  group('Sorting Set:', () {
    test('comparable entries', () {
      final s = {a, c, b}..sort();
      expect(s.first, a);
      expect(s.last, c);
    });
    test('explicit comparator', () {
      final s = {a, c, b}..sort(comparator);
      expect(s.first, c);
      expect(s.last, a);
    });
  });
  group('Map', () {
    test('{c:3, a:4, b:2}.sortByKey()', () {
      final map = {c: 3, a: 4, b: 2}..sortByKey();
      expect(map.keys.first, a);
      expect(map.values.first, 4);
      expect(map.keys.last, c);
      expect(map.values.last, 3);
    });
    test('{c:3, a:4, b:2}.sortByKey(comparator)', () {
      final map = {c: 3, a: 4, b: 2}..sortByKey(comparator);
      expect(map.keys.first, c);
      expect(map.values.first, 3);
      expect(map.keys.last, a);
      expect(map.values.last, 4);
    });

    test('{c:3, a:4, b:2}.sortByValue()', () {
      final map = {c: 3, a: 4, b: 2}..sortByValue();
      expect(map.keys.first, b);
      expect(map.values.first, 2);
      expect(map.keys.last, a);
      expect(map.values.last, 4);
    });
    test('{c:3, a:4, b:2}.sortByValue(comparator)', () {
      final map = {c: 3, a: 4, b: 2}..sortByValue(
          (left, right) => -left.compareTo(right),
        );
      expect(map.keys.first, a);
      expect(map.values.first, 4);
      expect(map.keys.last, b);
      expect(map.values.last, 2);
    });
  });
}
