import 'dart:math';
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
  Vector1.random(int size, {double scaleFactor = 0.01, int seed = SEED}) {
    Random rng = Random(seed);
    List<num> out = [];
    for (var i = 0; i < size; i++) {
      out.add(rng.nextDouble() * scaleFactor);
    }
    val = out;
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
}
