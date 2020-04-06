import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

/// To run the test, navigate to the folder 'directed_graph'
/// in your local copy of this library and use the command:
///
/// # pub run test -r expanded --test-randomize-ordering-seed=random
///
void main() {
  var red = Vertex<String>('red');
  var yellow = Vertex<String>('yellow');
  var orange = Vertex<String>('orange');
  var green = Vertex<String>('green');
  var blue = Vertex<String>('blue');
  var violet = Vertex<String>('violet');
  var gray = Vertex<String>('gray');
  var darkRed = Vertex<String>('darkRed');

  int comparator(
    Vertex<String> vertex1,
    Vertex<String> vertex2,
  ) {
    return vertex1.data.compareTo(vertex2.data);
  }

  var graph = DirectedGraph<String>(
    {
      orange: [red, yellow],
      green: [yellow, blue],
      violet: [red, blue],
      gray: [red, yellow, blue],
      red: [darkRed],
    },
    comparator: comparator,
  );

  group('Basic:', () {
    test('toString():', () {
      expect(
          graph.toString(),
          '{\n'
          ' blue: [],\n'
          ' darkRed: [],\n'
          ' gray: [red, yellow, blue],\n'
          ' green: [yellow, blue],\n'
          ' orange: [red, yellow],\n'
          ' red: [darkRed],\n'
          ' violet: [red, blue],\n'
          ' yellow: [],\n'
          '}');
    });
    test('for loop:', () {
      int index = 0;
      for (var vertex in graph) {
        expect(vertex, graph.vertices[index]);
        ++index;
      }
    });
  });
  group('Manipulating edges/vertices:', () {
    test('addEdges():', () {
      graph.addEdges(red, [green]);
      expect(graph.edges(red), [darkRed, green]);
      graph.removeEdges(red, [green]);
    });
    test('removeEdges():', () {
      graph.removeEdges(orange, [yellow]);
      expect(graph.edges(orange), [red]);
      graph.addEdges(orange, [yellow]);
    });
    test('remove():', () {
      graph.remove(gray);
      expect(graph.edges(gray), []);
      expect(graph.vertices.contains(gray), false);
      // Restore graph:
      graph.addEdges(gray, [red, yellow, blue]);
      expect(graph.vertices.contains(gray), true);
      expect(graph.edges(gray), [red, yellow, blue]);
    });
  });
  group('Graph data:', () {
    test('edges():', () {
      expect(graph.edges(orange), [red, yellow]);
    });
    test('indegree():', () {
      expect(graph.inDegree(red), 3);
    });
    test('indegree vertex with self-loop:', () {
      graph.addEdges(red, [red]);
      expect(graph.inDegree(red), 4);
      graph.removeEdges(red, [red]);
      expect(graph.inDegree(red), 3);
    });
    test('outDegree():', () {
      expect(graph.outDegree(gray), 3);
    });
    test('outDegreeMap():', () {
      expect(graph.outDegreeMap(), {
        blue: 0,
        darkRed: 0,
        green: 2,
        orange: 2,
        red: 1,
        violet: 2,
        gray: 3,
        yellow: 0,
      });
    });
    test('inDegreeMap:', () {
      graph.addEdges(red, [red]);
      expect(graph.inDegreeMap, {
        orange: 0,
        red: 4,
        yellow: 3,
        green: 0,
        blue: 3,
        violet: 0,
        gray: 0,
        darkRed: 1,
      });
      graph.removeEdges(red, [red]);
    });
    test('vertices():', () {
      expect(graph.vertices, [
        blue,
        darkRed,
        gray,
        green,
        orange,
        red,
        violet,
        yellow,
      ]);
    });
  });
  group('Topological ordering:', () {
    test('stronglyConnectedComponents():', () {
      expect(graph.stronglyConnectedComponents(), [
        [darkRed],
        [red],
        [yellow],
        [orange],
        [blue],
        [green],
        [violet],
        [gray],
      ]);
    });
    test('shortestPath():', () {
      graph.addEdges(red, [gray]);
      expect(graph.shortestPath(orange, gray), [red, gray]);
      graph.removeEdges(red, [gray]);
    });

    test('isAcyclic(): self-loop', () {
      graph.addEdges(red, [red]);
      expect(
        graph.isAcyclic(),
        false,
      );
      graph.removeEdges(red, [red]);
    });
    test('isAcyclic(): without cycles', () {
      expect(graph.isAcyclic(), true);
    });

    test('topologicalOrdering(): self-loop', () {
      graph.addEdges(blue, [blue]);
      expect(graph.topologicalOrdering(), null);
      graph.removeEdges(blue, [blue]);
    });
    test('topologicalOrdering(): cycle', () {
      graph.addEdges(red, [orange]);
      expect(graph.topologicalOrdering(), null);
      graph.removeEdges(red, [orange]);
    });
    test('topologicalOrdering():', () {
      expect(graph.topologicalOrdering(comparator), [
        gray,
        green,
        orange,
        violet,
        blue,
        red,
        darkRed,
        yellow,
      ]);
    });
    test('topologicalOrderingDFS():', () {
      expect(graph.topologicalOrderingDFS(), [
        gray,
        green,
        orange,
        violet,
        blue,
        red,
        darkRed,
        yellow,
      ]);
    });
    test('topologicalOrdering(): empty graph', () {
      expect(DirectedGraph<int>({}).topologicalOrderingDFS(), []);
    });
    test('localSource():', () {
      expect(graph.localSources(), [
        [orange, green, violet, gray],
        [red, yellow, blue],
        [darkRed],
      ]);
    });
  });
}
