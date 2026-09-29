extension EdgeCount<T extends Object> on Map<T, int> {
  /// Increments the edge count of the edge terminating at [key]
  /// and returns the current value.
  int increment(T key) {
    return update(key, (value) => value + 1, ifAbsent: () => 1);
  }

  /// Decrements the edge count of the edge terminating at [key]
  /// and return the current value.
  ///
  /// * Removes the edge if the edge count was 1.
  /// * Returns -1 if there is no edge terminating at [key].
  int decrement(T key) {
    if (containsKey(key)) {
      if (this[key] == 1) {
        return remove(key)! - 1;
      } else {
        return update(key, (value) => value - 1);
      }
    } else {
      return -1;
    }
  }
}
