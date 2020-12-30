## 0.3.0

* Added null-safety features.
* Functions returning a path now return an (ordered) set of vertices.
  (All vertices along a connected path must be distinct).
* Functions returning a topological ordering now return an ordered set of vertices.
* Added the classes `WeightedDirectedGraph` and `BiDirectedGraph`.
* Overhaul of class `GraphCrawler`.


## 0.2.0

Amended `README.md`.

## 0.1.9

* Moved `GraphCrawler` to a separate file.
* Amended graph crawler method `paths`.
* Added `DirectedGraph` constructor `.fromData`.

## 0.1.8

Corrected missing links in dartdocs.

## 0.1.7

Incorporated pedantic lint suggestions.
Updated docs.

## 0.1.6

Added info about class [`GraphCrawler`][GraphCrawler].

## 0.1.5

Added explicit generic type parameter to graph getter `iterator`.

## 0.1.4

Added class `GraphCrawler`.

Converted the following `DirectedGraph` methods to getters:
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

Specified type of the parameter `comparator` in `DirectedGraph` constructor.

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


[GraphCrawler]: https://pub.dev/documentation/directed_graph/latest/directed_graph/GraphCrawler-class.html