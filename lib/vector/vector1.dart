import 'dart:math' as math;
import 'package:flutter_nn/main.dart';

import 'root.dart';

class Vector1 extends Vector<num> {
  /// Create a 1D vector with a size of [size] filled with [fill].
  Vector1(int size, {num fill = 0}) {
    val = List.generate(size, (index) => fill);
  }

  /// Create a 1D vector from a 1D array
  Vector1.from(List<num> list) {
    val = List.from(list);
  }

  Vector1.fromVector(Vector1 vec) {
    val = List.from(vec.val);
  }

  /// Create an empty 1D vector
  Vector1.empty() {
    val = [];
  }

  /// Create a 1D vector of size [size] filled with random
  /// double values multiplied by [scaleFactor]. [seed] can be
  /// used to set the seed of the Random class from dart:math.
  Vector1.random(int size, {double scaleFactor = 0.01, int seed = seed}) {
    math.Random rng = math.Random(seed);
    List<num> out = [];
    for (var i = 0; i < size; i++) {
      out.add(rng.nextDouble() * scaleFactor);
    }
    val = out;
  }

  /// Create a vector of the same shape as the passed
  /// vector filled with the value of [fill]
  Vector1.like(Vector1 vec, {num fill = 0}) {
    val = List.generate(vec.length, (index) => fill);
  }

  @override
  String toString() => val.toString();

  num mean() => sum() / length;

  num sum({bool keepDims = true}) {
    num total = 0;
    for (var i in this) {
      total += i;
    }
    return total;
  }

  num max() {
    num max = 0;
    for (var i in this) {
      if (i > max) {
        max = i;
      }
    }
    return max;
  }

  num min() {
    num min = 100000;
    for (var i in this) {
      if (i < min) {
        min = i;
      }
    }
    return min;
  }

  Vector2 toVector2() {
    Vector2 out = Vector2.empty();
    for (num i in this) {
      out.add(Vector1.from([i]));
    }
    return out;
  }

  /// Get which index contains the max value
  int maxIndex() {
    int idx = 0;
    num max = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] > max) {
        idx = i;
        max = this[i];
      }
    }
    return idx;
  }

  /// normalize all of the values between 0 and 1
  Vector1 normalize() {
    Vector1 out = Vector1.empty();
    for (num i in this) {
      out.add((i - min()) / (max() - min()));
    }
    return out;
  }

  /// Get vector containing absolute values of all items
  Vector1 abs() {
    Vector1 out = Vector1.empty();
    for (num i in this) {
      if (i >= 0) {
        out.add(i);
      } else {
        out.add(-i);
      }
    }
    return out;
  }

  Vector1 replaceWhere(num Function(int index) logic) {
    Vector1 out = Vector1.like(this);
    for (int i = 0; i < length; i++) {
      out[i] = logic(i);
    }
    return out;
  }

  /// Take all values and raise e to the power of the value
  Vector1 exp() {
    Vector1 out = Vector1.empty();
    for (var i in this) {
      out.add(math.exp(i));
    }
    return out;
  }

  // take the natural log of all values
  Vector1 log() {
    Vector1 out = Vector1.empty();
    for (var i in this) {
      out.add(math.log(i));
    }
    return out;
  }
}
