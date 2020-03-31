# Generic Graph


## Benchmark

To run the benchmark program, navigate to the folder *directed_graph* in your downloaded
copy of this library and use
the following command:
```shell
# dart performance/bin/benchmark.dart
```

The program runs the benchmarked methods 10 times repeatedly for a minimum duration of
2000 milliseconds.
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
}, comparator: comparator);

// Benchmarked functions:
graph.topologicalOrdering(comparator);
graph.topologicalOrderingDFS();
graph.stronglyConnectedComponents();
```
A typical output for a benchmark run on a machine with a Intel Core Dual i5-6260U CPU @ 1.80GHz is listed below:
```shell
Topological Ordering DFS ...
[Wimbledon, Court 1, Tournament, Point, Game, Set, Match, Umpire, Team, Player]
Topological Ordering DFS:(RunTime): 27.160012493549527 us.

Topological Ordering Kahn ...
[Wimbledon, Court 1, Tournament, Point, Game, Set, Match, Team, Player, Umpire]
Topological Ordering Kahn(RunTime): 32.10741519641682 us.

Strongly Connected Components Tarjan ...
[[Player], [Team], [Umpire], [Match], [Set], [Game], [Point], [Tournament], [Court 1], [Wimbledon]]
Strongly Connected Componets Tarjan:(RunTime): 34.78822772260006 us.

This is the test graph:
Wimbledon ->
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
but `topologicalOrdering()` takes an optional comparator function as argument
and is able to generate a sorted topological ordering.


The method `stronglyConnectedComponents()` is provided for convenience only as it is simply calling the homonymously named function provided by the package [graphs].


## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs