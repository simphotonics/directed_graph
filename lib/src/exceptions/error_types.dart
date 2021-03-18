import 'package:exception_templates/exception_templates.dart';

/// Error detected while trying to access an object that is not a graph vertex.
class UnkownVertex extends ErrorType {}

/// Error detected while trying to traverse a path.
class InvalidPath extends ErrorType {}

/// The given pair of vertices do not form a graph edge.
class NotAnEdge extends ErrorType {}

/// Error thrown while attempting to sort objects of type `T` if:
/// * `T` does not extend `Comparable` **or**
/// * a valid `Comparator<T>` was not specified.
class SortingNotSupported<T> extends ErrorType {
  Type type = T;
}
