/// An ordered pair of objects.
class const Pair<T extends Object>(final T from, final T to) {
  /// Returns a pair where [from] and [to] are reversed.
  Pair<T> get reverse => Pair(to, from);

  @override
  String toString() {
    return '$from \u2192 $to';
  }

  @override
  int get hashCode => Object.hash(from, to);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Pair<T>) {
      return false;
    } else {
      if (from == other.from) {
        return to == other.to;
      } else {
        return false;
      }
    }
  }
}
