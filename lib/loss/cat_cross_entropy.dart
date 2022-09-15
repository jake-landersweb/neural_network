import 'dart:math' as math;
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/utils/root.dart';

/// To be used as the loss function for classification networks. These
/// will usually end with an output layer using a softmax activation function.
/// This does NOT support one-hot encoded lables, so they will have to be
/// converted to sparse labels
class LossCategoricalCrossentropy extends Loss {
  @override
  List<double> forward(List<List<double>> predictions, List<num> labels) {
    assert(predictions.length == labels.length,
        "The prediction length and label length need to match");
    List<double> loss = [];
    for (var i = 0; i < predictions.length; i++) {
      // need to avoid taking the log of 0
      // make the max value 1 - 1e-7, and min value 1e-7
      loss.add(-math.log(math.min(
          math.max(predictions[i][labels[i].round()], 1e-7), 1 - 1e-7)));
    }
    return loss;
  }
}
