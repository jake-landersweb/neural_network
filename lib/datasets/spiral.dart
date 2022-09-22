import 'dart:math';

import 'package:flutter_nn/constants.dart';

class SpiralDataset {
  late List<List<double>> X;
  late List<int> y;

  /// Generate a spiraled dataset
  SpiralDataset(int points, int classes,
      {int seed = seed, double randomFactor = 0.005}) {
    _generateData(points, classes, seed, randomFactor);
  }

  /// Generate the dataset with the values all shuffled
  SpiralDataset.shuffle(
    int points,
    int classes, {
    int seed = seed,
    double randomFactor = 0.005,
  }) {
    _generateData(points, classes, seed, randomFactor);
    List<List<double>> agg = [];
    for (int i = 0; i < X.length; i++) {
      List<double> tmp = [];
      tmp.addAll(X[i]);
      tmp.add(y[i].toDouble());
      agg.add(tmp);
    }
    // shuffle the list
    agg.shuffle(Random(seed));

    // recreate the lists
    List<List<double>> tempx = [];
    List<int> tempy = [];
    for (int i = 0; i < X.length; i++) {
      tempx.add([agg[i][0], agg[i][1]]);
      tempy.add(agg[i][2].round());
    }
    X = tempx;
    y = tempy;
  }

  void _generateData(
    int points,
    int classes,
    int seed,
    double randomFactor,
  ) {
    Random rng = Random(seed);
    X = List<List<double>>.filled(points * classes, [0, 0]);
    y = List<int>.filled(points * classes, 0);
    int ix = 0;
    for (int classNumber = 0; classNumber < classes; classNumber++) {
      double r = 0;
      double t = classNumber * 4;

      while (r <= 1 && t <= (classNumber + 1) * 4) {
        double randomT = t + rng.nextInt(points) * randomFactor;
        X[ix] = [r * sin(randomT * 2.5), r * cos(randomT * 2.5)];
        y[ix] = classNumber;

        // r += 1.0 / (points - 1);
        // t += 4.0 / (points - 1);
        r += 1.0 / (points);
        t += 4.0 / (points);

        ix++;
      }
    }
  }

  @override
  String toString() {
    return "X: $X\ny: $y";
  }
}
