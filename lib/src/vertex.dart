/// Generic object representing a vertex in a graph.
/// Holds data of type [T].
class Vertex<T> {
  final int _id;

  /// Vertex data of type [T].
  final T data;

  static int _counter = 0;

  /// Creates a vertex holding generic data of type [T].
  Vertex(this.data) : _id = ++_counter;

  /// Returns the (internal) integer [id] of the vertex.
  int get id => _id;

  @override
  bool operator ==(Object other) => other is Vertex<T> && other.id == _id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => '$data';
}
