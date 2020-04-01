import 'package:directed_graph/directed_graph.dart';
import 'package:test/test.dart';

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
          'orange -> \n'
          '  red, yellow\n'
          'green -> \n'
          '  yellow, blue\n'
          'violet -> \n'
          '  red, blue\n'
          'gray -> \n'
          '  red, yellow, blue\n'
          'red -> \n'
          '  darkRed\n'
          '');
    });
  });
  group('Graph:', () {
    test('addLinks():', () {
      graph.addEdges(red, [green]);
      expect(graph.edges(red), [darkRed, green]);
      graph.removeEdges(red, [green]);
    });
    test('removeLinks():', () {
      graph.removeEdges(orange, [yellow]);
      expect(graph.edges(orange), [red]);
      graph.addEdges(orange, [yellow]);
    });
    test('unLink():', () {
      graph.unLink(red);
      expect(graph.edges(red), []);
      graph.addEdges(red, [darkRed]);
    });
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
      expect(graph.outDegree(orange), 2);
    });
    test('outDegreeMap:', () {
      expect(graph.outDegreeMap(), {
        orange: 2,
        red: 1,
        yellow: 0,
        green: 2,
        blue: 0,
        violet: 2,
        gray: 3,
        darkRed: 0,
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
  });
}
