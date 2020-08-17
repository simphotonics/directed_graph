/// Library providing the `GraphCrawler`,
/// a utility class for finding paths connecting
/// two vertices.
library graph_crawler;

import 'dart:collection';
import 'package:meta/meta.dart';

import 'directed_graph.dart';

/// Crawls a graph defined by [edges] and records
/// the paths from `start` to `target`.
/// * Directed edges are walked only once.
class GraphCrawler<T> {
  GraphCrawler({
    @required this.edges,
  });

  /// Function returning a list of edge vertices or an empty list.
  /// It must never return `null`.
  final Edges<T> edges;

  /// Returns the first detected path from [start] to [target].
  List<Vertex<T>> path(Vertex<T> start, Vertex<T> target) {
    final _visited = <int, HashSet<int>>{};
    final _queue = Queue<Vertex<T>>();
    var path = <Vertex<T>>[];
    var pathFound = false;

    /// Recursive function that crawls the graph defined by
    /// `edges` and records the first path from [start] to [target].
    void _crawl(Vertex<T> start, Vertex<T> target) {
      // Return if a path has already been found.
      if (pathFound) {
        print('returning early');
        return;
      }
      _queue.addLast(start);
      for (final vertex in edges(start)) {
        if (vertex == target) {
          // Store result.
          path = List<Vertex<T>>.from(_queue);
          pathFound = true;
          return;
        } else {
          if (_visited[start.id] == null) {
            _visited[start.id] = HashSet();
            _visited[start.id].add(vertex.id);
            _crawl(vertex, target);
          }
          if (_visited[start.id].contains(vertex.id)) {
            continue;
          } else {
            _visited[start.id].add(vertex.id);
            _crawl(vertex, target);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty) {
        _queue.removeLast();
      }
    }

    _crawl(start, target);

    if (path.isEmpty) {
      return path;
    } else {
      return path..add(target);
    }
  }

  /// Returns the paths from [start] vertex to [target] vertex.
  ///
  /// * Each directed edge is walked only once.
  /// * The paths returned may include cycles if the graph is cyclic.
  ///
  /// The algorithm keeps track of the edges already walked to avoid an
  /// infinite loop when encountering a cycle.
  List<List<Vertex<T>>> paths(Vertex<T> start, Vertex<T> target) {
    final _visited = <int, HashSet<int>>{};
    final _pathList = <List<Vertex<T>>>[];
    final _queue = Queue<Vertex<T>>();

    /// Adds [this.target] to [path] and appends the result to [_paths].
    void _addPath(List<Vertex<T>> path) {
      // Add target vertex.
      path.add(target);
      _pathList.add(path);
    }

    /// Recursive function that crawls the graph defined by
    /// the function [edges] and records any path from [start] to [target].
    void _crawl(Vertex<T> start, Vertex<T> target) {
      // print('-----------------------');
      // print('Queue: $_queue');
      // print('Start: ${start} => target: ${target}.');
      _queue.addLast(start);
      for (final vertex in edges(start)) {
        // print('$start:${start.id} -> $vertex:${vertex.id}');
        // print('${start} -> ${vertex}');
        //stdin.readLineSync();
        //sleep(Duration(seconds: 2));
        if (vertex == target) {
          // print('|=======> Found target: recording '
          //     'result: $_queue');
          _addPath(_queue.toList());
        } else {
          if (_visited[start.id] == null) {
            _visited[start.id] = HashSet();
            _visited[start.id].add(vertex.id);
            _crawl(vertex, target);
          }
          if (_visited[start.id].contains(vertex.id)) {
            // print('${start} has visited ${vertex}');
            // print('Choose next vertex:');
            continue;
          } else {
            _visited[start.id].add(vertex.id);
            // print('$vertex added to visited.');
            _crawl(vertex, target);
          }
        }
      }
      // Stepping back along the path.
      if (_queue.isNotEmpty && _queue.last != target) {
        // print('Stepping back');
        // print('$_queue: removing: ${_queue.last}');
        // print('Clearing visited of ${_queue.last}: ${_queue.last._visited}');
        //_queue.removeLast()._visited.clear();
        _queue.removeLast();
      }
    }

    _crawl(start, target);

    return _pathList;
  }
}
