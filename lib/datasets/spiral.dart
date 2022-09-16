import 'dart:math';

import 'package:flutter_nn/main.dart';

class SpiralDataset {
  late List<List<double>> X;
  late List<int> y;

  SpiralDataset(int points, int classes, {int seed = SEED}) {
    _generateData(points, classes, seed);
  }

  void _generateData(int points, int classes, int seed) {
    Random rng = Random(SEED);
    X = List<List<double>>.filled(points * classes, [0, 0]);
    y = List<int>.filled(points * classes, 0);
    int ix = 0;
    for (int classNumber = 0; classNumber < classes; classNumber++) {
      double r = 0;
      double t = classNumber * 4;

      while (r <= 1 && t <= (classNumber + 1) * 4) {
        double randomT = t + rng.nextInt(points) * 0.008;
        X[ix] = [r * sin(randomT * 2.5), r * cos(randomT * 2.5)];
        y[ix] = classNumber;

        r += 1.0 / (points - 1);
        t += 4.0 / (points - 1);

        ix++;
      }
    }
  }

  @override
  String toString() {
    return "X: $X\ny: $y";
  }
}
