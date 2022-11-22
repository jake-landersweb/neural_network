import 'dart:math' as math;

/// Generate list of random values between 0 and 1
List<double> randomList1D(int size, {double scaleFactor = 0.01, int? seed}) {
  math.Random rng = math.Random(seed);
  List<double> out = [];
  for (var i = 0; i < size; i++) {
    var rand = rng.nextDouble() * scaleFactor;
    if (rng.nextBool()) {
      rand = -rand;
    }
    out.add(rand);
  }
  return out;
}

/// Generate list of random values between 0 and 1
List<List<double>> randomList2D(
  int rows,
  int cols, {
  double scaleFactor = 0.01,
  int? seed,
}) {
  List<List<double>> out = [];
  for (var i = 0; i < rows; i++) {
    out.add(randomList1D(cols, scaleFactor: scaleFactor, seed: seed));
  }
  return out;
}

/// Create a 2D vector from a 1D array in the form of [eye].
/// This will create a 2D vector in the size of [input.length, input.length],
/// with the values of the array making up the diagonal and the
/// rest of the values being filled with 0
/// For example, with a passed of array = [5,4,3], the created
/// vector will look like:
/// ```
/// [[5,0,0]
///  [0,4,0]
///  [0,0,3]]
/// ```
List<List<double>> diagonalFlat(List<double> input) {
  List<List<double>> out = [];
  for (var i = 0; i < input.length; i++) {
    List<double> temp = [];
    for (var j = 0; j < input.length; j++) {
      if (i == j) {
        temp.add(input[i]);
      } else {
        temp.add(0);
      }
    }
    out.add(temp);
  }
  return out;
}

/// Create a 2D vector that is of size [size, size].
/// Each diagonal will be filled with the value of [fill] (default 1),
/// and the rest of the values filled with 0.
/// For example, an eye of 3 will look like:
/// ```
/// [[1,0,0]
///  [0,1,0]
///  [0,0,1]]
/// ```
List<List<int>> eye(int size, {int fill = 1}) {
  List<List<int>> out = [];
  for (var i = 0; i < size; i++) {
    List<int> temp = [];
    for (var j = 0; j < size; j++) {
      if (i == j) {
        temp.add(fill);
      } else {
        temp.add(0);
      }
    }
    out.add(temp);
  }
  return out;
}

// List<double> like1D(List<double> list, {double fill = 0}) {
//   List<double> out = [];
//   for (int i = 0; i < list.length; i++) {
//     out.add(fill);
//   }
//   return out;
// }

// List<List<double>> like2D(List<List<double>> list, {double fill = 0}) {
//   List<List<double>> out = [];
//   for (var i in list) {
//     out.add(like1D(i, fill: fill));
//   }
//   return out;
// }

extension ListUtils1D on List<double> {
  /// Dot product
  double dot(List<double> other) {
    assert(length == other.length);
    double out = 0;
    for (int i = 0; i < length; i++) {
      out += this[i] * other[i];
    }
    return out;
  }

  /// Replace all values in list with specific rule
  List<double> replaceWhere(double Function(int i) func) {
    List<double> out = [];
    for (int i = 0; i < length; i++) {
      out.add(func(i));
    }
    return out;
  }

  /// return all values added together
  double sum() {
    double out = 0;
    for (var i in this) {
      out += i;
    }
    return out;
  }

  /// get max value from the list
  double max() {
    double out = -10000000;
    for (var i in this) {
      if (i > out) {
        out = i;
      }
    }
    return out;
  }

  /// wraps each value in list in its own list and returns
  /// as a 2D list
  List<List<double>> to2D() {
    List<List<double>> out = [];
    for (var i in this) {
      out.add([i]);
    }
    return out;
  }

  /// get the index of the max value in the list
  int maxIndex() {
    int out = 0;
    double max = -100000;
    for (int i = 0; i < length; i++) {
      if (this[i] > max) {
        out = i;
        max = this[i];
      }
    }
    return out;
  }

  List<int> get shape {
    return [length];
  }

  String numNeg() {
    int out = 0;
    for (var i in this) {
      if (i < 0) {
        out += 1;
      }
    }
    return "$out / $length";
  }
}

extension ListUtils2D on List<List<double>> {
  /// Transpose a 2D array
  List<List<double>> get T {
    List<List<double>> out = List.generate(this[0].length, (_) => []);

    for (var i = 0; i < length; i++) {
      for (var j = 0; j < this[i].length; j++) {
        out[j].add(this[i][j]);
      }
    }

    return out;
  }

  /// Dot with 1D array
  List<double> dot1D(List<double> other) {
    assert(first.length == other.length);
    List<double> out = [];
    for (int i = 0; i < length; i++) {
      out.add(this[i].dot(other));
    }
    return out;
  }

  /// Dot with 2D array
  List<List<double>> dot2D(List<List<double>> other) {
    assert(first.length == other.length);
    List<List<double>> out = [];
    for (var i in this) {
      List<double> col = [];
      for (var j in other.T) {
        col.add(i.dot(j));
      }
      out.add(col);
    }
    return out;
  }

  /// Replace all values in list with specific rule
  List<List<double>> replaceWhere(double Function(int i, int j) func) {
    List<List<double>> out = [];
    for (int i = 0; i < length; i++) {
      List<double> temp = [];
      for (int j = 0; j < this[i].length; j++) {
        temp.add(func(i, j));
      }
      out.add(temp);
    }
    return out;
  }

  /// get a list of the sums from all the inner lists
  List<double> sum() {
    List<double> out = [];
    for (var i in this) {
      out.add(i.sum());
    }
    return out;
  }

  List<int> get shape {
    return [length, first.length];
  }

  List<String> numNeg() {
    List<String> out = [];
    for (var i in this) {
      out.add(i.numNeg());
    }
    return out;
  }
}

class Tuple<I, J> {
  late I v1;
  late J v2;

  Tuple({
    required this.v1,
    required this.v2,
  });
}
