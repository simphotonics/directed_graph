extension Sort<T> on Set<T> {
  void sort(Comparator<T> comparator) {
    final tmp = List<T>.from(this)..sort(comparator);
    clear();
    addAll(tmp);
  }
}

extension SortMap<K, V> on Map<K, V> {
  void sort(Comparator<K> comparator) {
    final sortedKeys = List<K>.from(keys)..sort(comparator);
    final sortedValues = sortedKeys.map<V>((key) => this[key]!);
    addAll(Map<K, V>.fromIterables(sortedKeys, sortedValues));
  }
}
