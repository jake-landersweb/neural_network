import 'dart:math' as math;

import 'package:neural_network/network/utils.dart';

class CategoricalCrossentropy {
  List<double>? loss;

  double calculate(List<List<double>> predictions, List<int> labels) {
    loss = forward(predictions, labels);

    // return the mean of the loss values
    return loss!.sum() / loss!.length;
  }

  List<double> forward(List<List<double>> predictions, List<int> labels) {
    assert(predictions.length == labels.length);
    List<double> loss = [];

    for (var i = 0; i < predictions.length; i++) {
      // need to avoid taking the log of 0
      // make the max value 1 - 1e-7, and min value 1e-7
      loss.add(-math
          .log(math.min(math.max(predictions[i][labels[i]], 1e-7), 1 - 1e-7)));
    }
    return loss;
  }

  List<List<double>> backward(List<List<double>> dvalues, List<int> yTrue) {
    int samples = dvalues.length;
    int labels = dvalues[0].length;

    // convert labels to one-hot vector
    List<List<int>> eyeTemp = eye(labels);
    List<List<int>> oneHot = [];
    for (var i = 0; i < dvalues.length; i++) {
      oneHot.add(eyeTemp[yTrue[i]]);
    }
    return dvalues
        .replaceWhere((i, j) => (-oneHot[i][j] / dvalues[i][j]) / samples);
  }
}
