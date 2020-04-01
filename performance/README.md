# Directed Graph

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Test Graph
To set up the benchmark, the following directed graph is initialized:
```Dart
import 'package:directed_graph/directed_graph.dart';

// Function used to compare two vertices.
int comparator(
  Vertex<String> vertex1,
  Vertex<String> vertex2,
) {
  return vertex1.data.compareTo(vertex2.data);
}

// Directed graph
var player = Vertex<String>('Player');
var match = Vertex<String>('Match');
var _set = Vertex<String>('Set');
var game = Vertex<String>('Game');
var point = Vertex<String>('Point');
var team = Vertex<String>('Team');
var tournament = Vertex<String>('Tournament');
var umpire = Vertex<String>('Umpire');
var court1 = Vertex<String>('Court 1');
var grandSlam = Vertex<String>('GrandSlam');
var graph = DirectedGraph<String>({
  grandSlam: [tournament, court1],
  tournament: [team, player, match, _set, game, point, umpire],
  team: [player],
  match: [player, umpire],
  _set: [player, match],
  game: [player, _set],
  point: [player, game]
});
```
## Benchmark
The benchmark compares the average execution time of the functions:
`graph.topologicalOrdering(comparator)`,
`graph.topologicalOrderingDFS()` and
`graph.stronglyConnectedComponents()`.
Each function is run 10 times in a loop for a minimum duration of 2000 milliseconds.
This is the default setting provided by the package [benchmark_harness].

To run the benchmark program, navigate to the folder *directed_graph* in your downloaded
copy of this library and use
the following command:
```console
# dart performance/bin/benchmark.dart
```

A typical shell output for a benchmark run on a machine with a Intel Core Dual i5-6260U CPU @ 1.80GHz is listed below:
```console
Topological Ordering DFS ...
[GrandSlam, Tournament, Court 1, Team, Point, Game, Set, Match, Player, Umpire]
Topological Ordering DFS:(RunTime): 26.991969985289554 us.

Topological Ordering Kahn ...
[GrandSlam, Court 1, Tournament, Point, Game, Set, Match, Team, Player, Umpire]
Topological Ordering Kahn(RunTime): 32.20623188405797 us.

Strongly Connected Components Tarjan ...
[[Player], [Team], [Umpire], [Match], [Set], [Game], [Point], [Tournament], [Court 1], [GrandSlam]]
Strongly Connected Componets Tarjan:(RunTime): 36.057962392052936 us.

This is the test graph:
GrandSlam ->
  Tournament, Court 1
Tournament ->
  Team, Player, Match, Set, Game, Point, Umpire
Team ->
  Player
Match ->
  Player, Umpire
Set ->
  Player, Match
Game ->
  Player, Set
Point ->
  Player, Game
```
The method `topologicalOrderingDFS()`, based on a depth-first search algorithm, executes marginaly faster
but `topologicalOrdering()`, based on Kahn's algorithm, takes an optional comparator function as argument
and is able to generate a sorted topological ordering. In the example above the vertices are sorted in
topological and lexicographical order.

The method `stronglyConnectedComponents()` is provided for convenience
only as it is simply calling the homonymously named function provided by the package [graphs].


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[benchmark_harness]: https://pub.dev/packages/benchmark_harness
[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs