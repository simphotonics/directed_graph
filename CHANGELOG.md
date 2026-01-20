
## 0.5.1
- The graph `length` is now calculated using an efficient length iterable
  (the keys of the map storing the graph edges).
  The function `reachableVertices` is not based on a recursive algorithm that
  is speeds up execution time.
- Extended the definition of a quasi-topological ordering.
- Lowered the required SDK version to ^3.5.0. 

## 0.5.0
- *Breaking changes*:
  The following *getters have been converted to functions*, to
  reflect the fact that a potentially long computation is be needed to
  calculate the result:
    * `stronglyConnectedComponents({bool sorted, Comparator <T> comparator})`
      and the function return type has been
      changed to `List<Set>` to show the fact that each scc is a set
      of vertices and to make searching a component for a specify vertex more
      efficient,
    * `topologicalOrdering({bool sorted})`,
    * `cycle()`,
    * `localSource()`.
- The getters `cycleVertex` and `isAcyclic` were kept, but are now cached and
  only updated if vertices or edges are added/removed.

- The getter `sortedTopologicalOrdering` was removed. To get the equivalent
  result call `topologicalOrdering(sorted:true)`.
- *New additions*:
    * `addEdge({vertex, connectedVertex})` was added to `DirectedGraph` and
    `BiDirectedGraph` to make
    it consistent with `WeightedDirectedGraph`,
    * `reverseTopologicalOrdering({bool sorted})`, for the meaning of
       quasi-topological ordering see Section Terminology of README.md.
    * `quasiTopologicalOrdering({bool sorted})`,
    * `reverseQuasiTopologicalOrdering({bool sorted})`.
- Fixed a bug related to the addition of a default comparator if the
  generic type `T` of `DirectedGraph<T>` is `Comparable<T>`.
- Updated dependencies.


## 0.4.5
- Updated dependencies.
- Updated benchmark report.

## 0.4.4
- Fixed bug where cache was updated after calling the method `addEdge`
   on an instance of type
  `WeightedDirectedGraph`.
- Updated dependencies.
- Updated benchmark_runner version and benchmark report.

## 0.4.3
- Updated deps.

## 0.4.2
- Updated deps.
- Added topics to `pubspec.yaml`.

## 0.4.1
- Updated section Usage.
- Updated dependencies.
- Applied suggested lints.

## 0.4.0
- Updated dependencies.
- Library now uses latest version of [`lazy_memo`][lazy_memo].
- Removed dependency on [`graphs`][graphs].
- Benchmarks now using [`benchmark_runner`][benchmark_runner].


## 0.3.9
- Updated dependencies.
- Amended extensions in `sort.dart`.
- Sorting is now possible without specifying a `Comparator` as long as the
  the vertex type `T` implements `Comparable`.
- Added tests.

## 0.3.8
- Updated dependencies.
- Applied suggested lints.

## 0.3.7
- Updated deps.
- Added graph methods `edgeExists` and `vertexExists`.

## 0.3.6

- Replace package `pedantic` with `lints`.
- Updated deps.

## 0.3.5

- Amended docs. Migrated from travis to github actions.

## 0.3.4

- Eliminated cyclic dependency between class [`WeightedDirectedGraph`][WeightedDirectedGraph]
  and extension `GraphUtils`.
- Added getter `crawler`.
- Added the method `clear()` to classes [`DirectedGraph`][DirectedGraph] and
[`WeightedDirectedGraph`][WeightedDirectedGraph].

## 0.3.3

- Added weighted graph getter `transitiveWeightedEdges` and method `addEdge()`.

## 0.3.2

- Amended factory constructor `DirectedGraph.transitiveClosure()`.

## 0.3.1

* Amended documentation.

## 0.3.0

* Added null-safety features.
* Tightened the definition of path.
  A path \[v<sub>i</sub>, ...,   v<sub>n</sub>\] is an ordered list of at least two connected vertices where each *inner* vertex is *distinct*.
* Functions returning a topological ordering now return an ordered set of vertices, reflecting the fact that in a topological ordering
  each vertex must be distinct.
* Added the classes [`WeightedDirectedGraph`][WeightedDirectedGraph] and `BiDirectedGraph`.
* Complete overhaul of the class `GraphCrawler`.

## 0.2.3

Added [`GraphCrawler`][GraphCrawler] method `tree`.
Amended methods `path` and `paths`.

## 0.2.2

Added the getter `data`.

## 0.2.1

Removed debug print statement.

## 0.2.0

Amended `README.md`.

## 0.1.9

* Moved [`GraphCrawler`][GraphCrawler] to a separate file.
* Amended graph crawler method `paths`.
* Added [`DirectedGraph`][DirectedGraph] constructor `.fromData`.

## 0.1.8

Corrected missing links in dartdocs.

## 0.1.7

Incorporated pedantic lint suggestions.
Updated docs.

## 0.1.6

Added info about class [[`GraphCrawler`][GraphCrawler]][GraphCrawler].

## 0.1.5

Added explicit generic type parameter to graph getter `iterator`.

## 0.1.4

Added class [`GraphCrawler`][GraphCrawler].

Converted the following [`DirectedGraph`][DirectedGraph] methods to getters:
- `isAcyclic`,
- `localSources`,
- `outDegreeMap`,
- `sortedTopologicalOrdering`,
- `stronglyConnectedComponents`,
- `topologicalOrdering`.

Added methods for finding cycles in cyclic graphs:
- `cycle`
- `findCycle()`

## 0.1.3

Specified type of the parameter `comparator` in [`DirectedGraph`][DirectedGraph] constructor.

## 0.1.2

Amended equality operator of `ConstantVertex`.

## 0.1.1

Amended section ##Usage in README.md.

## 0.1.0

Fixed logic in `removeEdges()`.
The field comparator is no longer final, it can
be set to trigger a resort of the graph vertices.

## 0.0.5

Edited image url.

## 0.0.4

Added method localSources().
DirectedGraph now extends Iterator.

## 0.0.3

Amended README.md, included travis icon.

## 0.0.2

Amended package description.

## 0.0.1

Initial version of the library.

[DirectedGraph]: https://pub.dev/documentation/directed_graph/latest/directed_graph/DirectedGraph-class.html

[WeightedDirectedGraph]: https://pub.dev/documentation/directed_graph/latest/directed_graph/WeightedDirectedGraph-class.html

[GraphCrawler]: https://pub.dev/documentation/directed_graph/latest/directed_graph/GraphCrawler-class.html

[benchmark_runner]: https://pub.dev/packages/benchmark_runner
[lazy_memo]: https://pub.dev/packages/lazy_memo
[graphs]: https://pub.dev/packages/graphs