import 'package:directed_graph/src/exceptions/error_types.dart';
import 'package:exception_templates/exception_templates.dart';

/// Extension providing the method [sort] for
/// sorting a `Set<T extends Object>` in place.
extension SortSet<T extends Object> on Set<T> {
  void sort([Comparator<T>? comparator]) {
    if (isEmpty) return;
    final tmp = List<T>.of(this);
    if (first is Comparable) {
      tmp.sort(
          comparator ?? (left, right) => (left as Comparable).compareTo(right));
    } else if (first is num) {
      tmp.sort(
          comparator ?? (left, right) => (left as num).compareTo(right as num));
    } else {
      throw ErrorOfType<SortingNotSupported<T>>(
          message: 'Error trying to sort the set $this.',
          invalidState: 'Type \'$T\' is not comparable.',
          expectedState: 'Try specifying a valid comparator for type \'$T\'.');
    }
    clear();
    addAll(tmp);
  }
}

/// Extension providing the methods [sortByKey]
/// and [sortByValue] for
/// sorting a `Map<K extends Object, V extends Object>` in place.
extension SortMap<K extends Object, V extends Object> on Map<K, V> {
  /// Sorts a map of type `Map<K, V>` (in place) using the map keys.
  ///
  /// Note: If `K` does not extend `Comparable` a valid `Comparator<K>`
  void sortByKey([Comparator<K>? comparator]) {
    final tmp = entries.toList();
    if (isEmpty) return;
    if (keys.first is Comparable) {
      tmp.sort((left, right) => (comparator == null)
          ? (left.key as Comparable).compareTo(right.key)
          : comparator(left.key, right.key));
    } else if (keys.first is num) {
      tmp.sort((left, right) => (comparator == null)
          ? (left.key as num).compareTo(right.key as num)
          : comparator(left.key, right.key));
    } else {
      throw ErrorOfType<SortingNotSupported<K>>(
          message: 'Error trying to sort $this using the keys $keys.',
          invalidState: 'Type \'$K\' is not comparable.',
          expectedState: 'Try specifying a valid comparator for type \'$K\'.');
    }
    clear();
    addEntries(tmp);
  }

  /// Sorts a map of type `Map<K, V>` (in place) using the map values.
  ///
  /// Note: Since `V` does not extend `Comparable` a valid `Comparator<V>`
  /// is required.
  void sortByValue([Comparator<V>? comparator]) {
    final tmp = entries.toList();
    if (isEmpty) return;
    if (values.first is Comparable) {
      tmp.sort((left, right) => (comparator == null)
          ? (left.value as Comparable).compareTo(right.value)
          : comparator(left.value, right.value));
    } else if (values.first is num) {
      tmp.sort((left, right) => (comparator == null)
          ? (left.value as num).compareTo(right.value as num)
          : comparator(left.value, right.value));
    } else {
      throw ErrorOfType<SortingNotSupported<K>>(
          message: 'Error trying to sort a map of type Map<$K, $V>.',
          invalidState: 'Type \'$V\' is not comparable.',
          expectedState: 'Try calling sortByValue() specifying '
              'a valid comparator for type \'$V\'.');
    }
    clear();
    addEntries(tmp);
  }
}
