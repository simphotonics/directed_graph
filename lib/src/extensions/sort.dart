import 'package:directed_graph/src/exceptions/error_types.dart';
import 'package:exception_templates/exception_templates.dart';

/// Returns a generic function of type [Comparator] or `null` if [T] does not
/// implement [Comparable].
Comparator<T>? defaultComparator<T>() {
  if (Iterable<T>.empty() is Iterable<Comparable>) {
    return (T left, T right) => (left as Comparable).compareTo(right);
  } else {
    return null;
  }
}

/// Extension providing the method [equalTo] for
/// sorting a set with another set element by element.
extension CompareSet<T extends Object> on Set<T> {
  /// Returns `true` if `this` contains the same elements as [other]
  /// and the elements occur in the same order.
  bool equalTo(Set<T> other) {
    final it = iterator;
    final oit = other.iterator;

    while (it.moveNext() && oit.moveNext()) {
      if (it.current != oit.current) {
        return false;
      }
    }
    return true;
  }
}

/// Extension providing the method [sort] for
/// sorting a `Set<T extends Object>` in place.
extension SortSet<T extends Object> on Set<T> {
  /// Sorts the set in place.
  ///
  /// * Works with `LinkedHashSet`, the default implementation of [Set].
  /// * Sorting is nonsensical for instances of `HashSet` since
  ///   the iteration order is *not* specified.
  void sort([Comparator<T>? comparator]) {
    if (isEmpty) {
      return;
    }
    final tmp = toList();
    if (comparator != null) {
      tmp.sort(comparator);
    } else if (first is Comparable) {
      tmp.sort(defaultComparator<T>()); // Sort using default comparator.
    } else {
      throw ErrorOfType<SortingNotSupported<T>>(
        message: 'Error trying to sort the set: $this.',
        invalidState: 'Type \'$T\' does not implement Comparable<$T>.',
        expectedState: 'Try specifying a valid comparator for type \'$T\'.',
      );
    }
    clear();
    addAll(tmp);
  }

  /// Reverses the element order in place.
  /// * Works with `LinkedHashSet`, the default implementation of [Set].
  void reverse() {
    if (isEmpty) return;
    if (length == 1) return;
    final elements = toList().reversed;
    clear();
    addAll(elements);
  }
}

/// Extension providing the methods [sortByKey]
/// and [sortByValue] for
/// sorting a `Map<K extends Object, V extends Object>` in place.
extension SortMap<K extends Object, V extends Object> on Map<K, V> {
  /// Sorts a map of type `Map<K, V>` (in place) using the map keys.
  ///
  /// Note: If `K` does not extend `Comparable` a valid `Comparator<K>`
  /// must be provided.
  void sortByKey([Comparator<K>? comparator]) {
    if (isEmpty) {
      return;
    }
    final sortedKeys = keys.toList();

    if (comparator != null) {
      sortedKeys.sort(comparator);
    } else if (sortedKeys.first is Comparable) {
      sortedKeys.sort(defaultComparator<K>());
    } else {
      throw ErrorOfType<SortingNotSupported<K>>(
        message: 'Error trying to sort $this using the keys $keys.',
        invalidState: 'Type \'$K\' is not comparable.',
        expectedState: 'Try calling sortByKey() '
            'specifying a valid comparator for type \'$K\'.',
      );
    }
    // Construct new map.
    final map = {for (var key in sortedKeys) key: this[key]!};
    // Clear old entries.
    clear();
    // Add new entries.
    addAll(map);
  }

  /// Sorts a map of type `Map<K, V>` (in place) using the map values.
  ///
  /// Note: If `V` does not extend `Comparable` a valid `Comparator<V>`
  /// is required.
  void sortByValue([Comparator<V>? comparator]) {
    if (isEmpty) {
      return;
    }

    final tmp = entries.toList();
    if (comparator != null) {
      tmp.sort((left, right) => comparator(left.value, right.value));
    } else if (values.first is Comparable) {
      tmp.sort(
        (left, right) => (left.value as Comparable).compareTo(right.value),
      );
    } else {
      throw ErrorOfType<SortingNotSupported<V>>(
        message: 'Error trying to sort a map of type Map<$K, $V>.',
        invalidState: 'Type \'$V\' is not comparable.',
        expectedState: 'Try calling sortByValue() specifying '
            'a valid comparator for type \'$V\'.',
      );
    }
    clear();
    addEntries(tmp);
  }
}
