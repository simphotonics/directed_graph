class Vertex<T> {
  Vertex(this.data);
  T data;

  toString() {
    return '($data: $hashCode)';
  }
}

class Stringg {
  Stringg(this.value);
  String value;

  @override
  String toString() {
    return value;
  }
}

enum Primary { red, blue, green }

void main() {
  var a0 = Stringg('a');
  var a = Vertex<Stringg>(a0);
  var b = Vertex(Stringg('b'));
  var c = Vertex(Stringg('c'));

  final map = {a: a0, b: a0};
  a0.value = 'AA';
  print(map);

  a = c;

  map[c] = Stringg('d');
  map.remove(a);
  print(a);

  a = map.keys.first;

  print(a);

  print(map);

  final list = [a, b, c];
  print(list);

  print('a'.hashCode);

  var aa = 'a';
  print(aa.hashCode);
  print('a'.hashCode);

  var list1 = [aa];
  list1.first = '8';
  print(list1.first.hashCode);
}
