import 'dart:math' as math;
import 'package:flutter_nn/main.dart';

import 'root.dart';

class Vector2 extends Vector<Vector1> {
  Vector2 get T {
    List<List<num>> out = List.generate(this[0].length, (_) => []);

    for (var i = 0; i < length; i++) {
      for (var j = 0; j < this[i].length; j++) {
        out[j].add(this[i][j]);
      }
    }

    return Vector2.from(out);
  }

  /// Generate an empty 2D vector of [rows, height]
  Vector2(int rows, int cols, {num fill = 0}) {
    val = List.generate(
      rows,
      (_) => Vector1(cols, fill: fill),
    );
  }

  /// Create a 2D vector from a 2D array
  Vector2.from(List<List<num>> list) {
    val = List.from([for (var i in list) Vector1.from(i)]);
  }

  Vector2.fromVector(Vector2 vec) {
    val = List.from([for (var i in vec.val) Vector1.fromVector(i)]);
  }

  // Create an empty 2D vector
  Vector2.empty() {
    val = [];
  }

  /// Create a 2D vector of size [rows, cols] filled with
  /// random values multipled by [scaleFactor]. [seed] can
  /// be used to set the value of the Random class from dart:math.
  Vector2.random(int rows, int cols,
      {double scaleFactor = 0.01, int seed = SEED}) {
    math.Random rng = math.Random(seed);
    Vector2 list = Vector2.empty();
    for (var i = 0; i < rows; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < cols; j++) {
        var rand = rng.nextDouble() * scaleFactor;
        if (rng.nextBool()) {
          rand = -rand;
        }
        temp.add(rand);
      }
      list.add(temp);
    }
    val = list.val;
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
  Vector2.eye(int size, {int fill = 1}) {
    Vector2 out = Vector2.empty();
    for (var i = 0; i < size; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < size; j++) {
        if (i == j) {
          temp.add(fill);
        } else {
          temp.add(0);
        }
      }
      out.add(temp);
    }
    val = out.val;
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
  Vector2.diagonalFlat(List<num> input) {
    Vector2 out = Vector2.empty();
    for (var i = 0; i < input.length; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < input.length; j++) {
        if (i == j) {
          temp.add(input[i]);
        } else {
          temp.add(0);
        }
      }
      out.add(temp);
    }
    val = out.val;
  }

  @override
  String toString({int precision = 6}) {
    String calc(Vector2 list, bool exp, int startIndex) {
      late String out;
      if (startIndex == 0) {
        out = "[";
      } else {
        out = " ";
      }
      for (var i = 0; i < list.length; i++) {
        out += " ${startIndex + i} [";
        for (var j = 0; j < list[i].length; j++) {
          if (!list[i][j].isNegative) {
            out += " ";
          }
          if (exp) {
            out += list[i][j].toStringAsExponential(precision);
          } else {
            out += list[i][j].toStringAsFixed(precision);
          }
          if (j != list[i].length - 1) {
            out += " ";
          }
        }
        out += "]";
        if (i != list.length - 1) {
          out += "\n ";
        } else {
          out += "]";
        }
      }
      return out;
    }

    if (length > 10) {
      Vector2 beg = subVector(0, 5) as Vector2;
      Vector2 end = subVector(length - 5, length) as Vector2;
      String out1 =
          calc(beg, beg.any((e1) => e1.any((e2) => e2 != 0 && e2 < 0.001)), 0);
      String out2 = calc(
          end,
          end.any((e1) => e1.any((e2) => e2 != 0 && e2 < 0.001)),
          val.length - 5);
      return "$out1\n  ...\n$out2";
    } else {
      return calc(
          this, val.any((e1) => e1.any((e2) => e2 != 0 && e2 < 0.001)), 0);
    }
  }

  @override
  Vector sum({int axis = 0, bool keepDims = true}) {
    if (keepDims) {
      if (axis == 0) {
        Vector1 temp = Vector1.empty();
        for (Vector1 i in T) {
          temp.add(i.sum());
        }
        Vector2 out = Vector2.from([temp.val]);
        return out;
      } else {
        Vector2 out = Vector2.empty();
        for (Vector1 i in this) {
          out.add(Vector1.from([i.sum()]));
        }
        return out;
      }
    } else {
      Vector1 out = Vector1.empty();
      for (Vector1 i in T) {
        num v = 0;
        for (var j in i) {
          v += j;
        }
        out.add(v);
      }
      return out;
    }
    // Vector1 out = Vector1.empty();
    // for (Vector1 i in this) {
    //   out.add(i.sum().first);
    // }
    // if (keepDims) {
    //   return Vector2.from([
    //     for (var i in out.val) [i]
    //   ]);
    // } else {
    //   return out;
    // }
  }

  /// Convert the [Vector2] into a [Vector1] where the
  /// value of each element in the [Vector1] equals the
  /// index of the max value inside the nested [Vector1]
  /// inside the original [Vector2].
  Vector1 flatMax() {
    Vector1 out = Vector1.empty();
    for (Vector1 i in this) {
      out.add(i.maxIndex());
    }
    return out;
  }

  Vector2 pow(num value) {
    Vector2 out = Vector2.fromVector(this);

    for (var i = 0; i < out.length; i++) {
      for (var j = 0; j < out[i].length; j++) {
        out[i][j] = math.pow(out[i][j], value);
      }
    }
    return out;
  }

  Vector2 sqrt() {
    Vector2 out = Vector2.fromVector(this);

    for (var i = 0; i < out.length; i++) {
      for (var j = 0; j < out[i].length; j++) {
        out[i][j] = math.sqrt(out[i][j]);
      }
    }
    return out;
  }
}
