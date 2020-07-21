

[![Build Status](https://travis-ci.com/simphotonics/directed_graph.svg?branch=master)](https://travis-ci.com/simphotonics/directed_graph)

## Directed Graph - Example
The file [`example.dart`][example.dart] (see folder *bin*) contains a short program that demonstrates how to create
a numerical representation of the directed graph shown in the figure below using the package [`directed_graph`][directed_graph].

The program also shows how to add/remove vertices and edges, determine if the graph is acyclic, or
obtain a list of vertices in topological order.

![Directed Graph Image](https://raw.githubusercontent.com/simphotonics/directed_graph/master/images/directed_graph.svg?sanitize=true)

The methods `stronglyConnectedComponents` and `shortestPath` are provided for convenience
only as they are simply calling the homonymously named functions provided by the package [`graphs`][graphs].

The program can be run in a terminal by navigating to the
folder *directed_graph/example* in your local copy of this library and using the command:
```Console
$ dart bin/example.dart
```

## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/directed_graph/issues
[graphs]: https://pub.dev/packages/graphs
[directed_graph]: https://github.com/simphotonics/directed_graph/
[example.dart]: https://github.com/simphotonics/directed_graph/blob/master/example/bin/example.dart