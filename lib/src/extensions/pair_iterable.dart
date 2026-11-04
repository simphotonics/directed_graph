import '../graph/pair.dart';

extension PairIterable<T extends Object> on Iterable<T> {
  Iterable<Pair<T>> get pairIterable sync* {
    if (isEmpty) return;
    final it = iterator;
    if (!it.moveNext()) {
      return;
    }
    var from = it.current;
    while (it.moveNext()) {
      yield Pair(from, it.current);
      from = it.current;
    }
  }
}
