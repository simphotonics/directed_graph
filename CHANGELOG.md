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
  A path \[v<sub>i</sub>, ...,   v<sub>n</sub>\] is an ordered list of at least two connected vertices where each **inner** vertex is **distinct**.
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
