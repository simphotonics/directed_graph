import 'package:test/test.dart';
import 'package:directed_graph/directed_graph.dart';

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
void main() {
  group('Pair iterable:', () {
    test('empty', () {
      expect(<String>[].pairIterable, isEmpty);
    });

    test('one element', () {
      expect([a].pairIterable, isEmpty);
    });
    test('[a, b]', () {
      expect([a, b].pairIterable.first, Pair(a, b));
    });
    test('second', () {
      expect([a, b, c].pairIterable.elementAt(1), Pair(b, c));
    });
    test('last', () {
      expect([a, b, c, d, e].pairIterable.last, Pair(d, e));
    });

    test('toString', () {
      expect([a, b, c, d].pairIterable.toString(), '(a → b, b → c, c → d)');
    });
  });
}
