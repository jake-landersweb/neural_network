import 'root.dart';

abstract class Vector<T> implements Iterable {
  /// Vector is a wrapper for a list of T
  /// T can either be of type num or type Vector1
  late List<T> val;

  /// Get the size of the vector in an array. If the
  /// vector is [Vector1], the list will contain 1
  /// element of the length. If the vector is [Vector2],
  /// the list will contain 2 elements, [rows, cols].
  List<int> get shape {
    if (this is Vector1) {
      return [length];
    } else if (this is Vector2) {
      return [length, (this[0] as Vector1).length];
    } else {
      throw "Vector is not of type Vector1 or Vector2";
    }
  }

  // get methods overriden
  @override
  int get length => val.length;

  @override
  T get first => val.first;

  @override
  T get last => val.last;

  @override
  bool get isEmpty => val.isEmpty;

  @override
  bool get isNotEmpty => val.isNotEmpty;

  @override
  Type get runtimeType => Vector;

  /// Add an item to the vector. Must match the list
  /// type. [num] for [Vector1] and [Vector1] for [Vector2]
  void add(T value) {
    val.add(value);
  }

  /// Add a list of values to the end of the vector.  Must match
  /// the list type. [num] for [Vector1] and [Vector1] for [Vector2]
  void addAll(List<T> values) {
    val.addAll(values);
  }

  @override
  bool any(bool Function(T) callback) {
    for (var i in val) {
      if (callback(i)) {
        return true;
      }
    }
    return false;
  }

  /// Implemented in the same way as `List.subList(start, [int? end])`.
  /// Requires the [start] index, and optionally takes an [end] index.
  Vector subVector(int start, [int? end]) {
    if (this is Vector1) {
      return Vector1.from(val.sublist(
          start,
          end == null
              ? null
              : end > length
                  ? length
                  : end) as List<num>);
    } else if (this is Vector2) {
      List<Vector1> temp = val.sublist(
          start,
          end == null
              ? null
              : end > length
                  ? length
                  : end) as List<Vector1>;
      Vector2 out = Vector2.empty();
      out.val = temp;
      return out;
    } else {
      throw "Vector is not of type Vector1 or Vector2";
    }
  }

  @override
  Iterable<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  bool contains(Object? element) {
    if (element is T && runtimeType == element.runtimeType) {
      return val.contains(element);
    } else {
      return false;
    }
  }

  @override
  T elementAt(int index) {
    return val[index];
  }

  @override
  bool every(bool Function(dynamic element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(dynamic element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  firstWhere(bool Function(dynamic element) test, {Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  T fold<T>(
      T initialValue, T Function(T previousValue, dynamic element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Iterable followedBy(Iterable other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(T element) action) {
    for (var i in val) {
      action(i);
    }
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => val.iterator;

  @override
  String join([String separator = ""]) {
    String out = "";
    for (var i = 0; i < length; i++) {
      out += val[i].toString();
      if (i != length) {
        out += separator;
      }
    }
    return out;
  }

  @override
  lastWhere(bool Function(dynamic element) test, {Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  Iterable<T> map<T>(T Function(dynamic e) toElement) {
    return val.map<T>(toElement);
  }

  @override
  reduce(Function(dynamic value, dynamic element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  // TODO: implement single
  get single =>
      length == 1 ? val[0] : throw StateError("Vector is not 0 > length < 1");

  @override
  singleWhere(bool Function(dynamic element) test, {Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable skipWhile(bool Function(dynamic value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  Iterable take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable takeWhile(bool Function(dynamic value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List toList({bool growable = true}) {
    return val;
  }

  @override
  Set toSet() {
    return val.toSet();
  }

  @override
  Iterable where(bool Function(dynamic element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) {
    if (other is Vector && runtimeType == other.runtimeType) {
      for (var i = 0; i < length; i++) {
        if (val[i] != other.val[i]) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  // operators

  /// List comprehension
  T operator [](int index) => val[index];
  void operator []=(int index, T item) => val[index] = item;

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator +(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 + x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator -(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 - x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator *(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 * x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector operator /(dynamic other) {
    return _arithmetic(other, (x1, x2) => x1 / x2);
  }

  /// Arithmetic can be performed on the vector. [other] can be of 3
  /// different types: [Vector1], [Vector2], and [num]. On operators
  /// that are not bi-directional, the workaround is to either
  /// multiply the result by negative 1, or use the `replaceWhere`
  /// method.
  Vector _arithmetic(dynamic other, num Function(num x1, num x2) arithmetic) {
    // check if other is of type num
    if (other is num) {
      if (this is Vector1) {
        Vector1 out = Vector1.empty();
        for (num i in val as List<num>) {
          out.add(arithmetic(i, other));
        }
        return out;
      } else if (this is Vector2) {
        Vector2 out = Vector2.fromVector(this as Vector2);
        for (var i = 0; i < length; i++) {
          for (var j = 0; j < out[i].length; j++) {
            out[i][j] = arithmetic(out[i][j], other);
          }
        }
        return out;
      } else {
        throw "Vector is not of type Vector1 or Vector2";
      }
    }
    // determine types of vectors to add
    if (this is Vector1) {
      if (other is Vector1) {
        // both 1D
        assert(
          val.length == other.val.length,
          "Both vectors need to be the same length",
        );
        Vector1 list = Vector1.empty();
        for (var i = 0; i < val.length; i++) {
          list.add(arithmetic((val[i] as num), (other.val[i])));
        }
        return list;
      } else {
        // this is 1D, other is 2D
        assert(
          val.length == (other.val[0] as Vector1).length,
          "The first vector's length needs to match the elements inside the second vector's length",
        );
        Vector2 list = Vector2.empty();
        for (var i = 0; i < other.val.length; i++) {
          Vector1 temp = Vector1.empty();
          for (var j = 0; j < (other.val[i] as Vector1).length; j++) {
            temp.add(arithmetic((val[j] as num), other.val[i][j]));
          }
          list.add(temp);
        }
        return list;
      }
    } else {
      if (other is Vector1) {
        // this is 2D, other is 1D
        assert(
          (val[0] as Vector1).length == other.val.length,
          "The first vector item's length needs to match the second vector's length",
        );
        Vector2 list = Vector2.empty();
        for (var i = 0; i < val.length; i++) {
          Vector1 temp = Vector1.empty();
          for (var j = 0; j < (val[i] as Vector1).length; j++) {
            temp.add(arithmetic((other.val[j]), (val[i] as Vector1)[j]));
          }
          list.add(temp);
        }
        return list;
      } else {
        // both 2D
        Vector2 list = Vector2.empty();

        for (var i = 0; i < val.length; i++) {
          Vector1 temp = Vector1.empty();
          for (var j = 0; j < (val[i] as Vector1).length; j++) {
            if (other[0].length == 1) {
              if (other.length == 1) {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[0] as Vector1)[0]));
              } else {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[i] as Vector1)[0]));
              }
            } else {
              if (other.length == 1) {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[0] as Vector1)[j]));
              } else {
                temp.add(arithmetic(
                    (val[i] as Vector1)[j], (other.val[i] as Vector1)[j]));
              }
            }
          }
          list.add(temp);
        }
        return list;
      }
    }
  }

  @override
  int get hashCode => val.hashCode;
}
