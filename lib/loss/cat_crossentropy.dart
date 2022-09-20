import 'dart:math' as math;
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/vector/root.dart';

/// To be used as the loss function for classification networks. These
/// will usually end with an output layer using a softmax activation function.
class LossCategoricalCrossentropy extends Loss {
  @override
  Vector1 forward(Vector2 predictions, Vector1 labels) {
    assert(predictions.length == labels.length,
        "The prediction length and label length need to match");
    Vector1 loss = Vector1.empty();

    for (var i = 0; i < predictions.length; i++) {
      // need to avoid taking the log of 0
      // make the max value 1 - 1e-7, and min value 1e-7
      loss.add(-math.log(math.min(
          math.max(predictions[i][labels[i].round()], 1e-7), 1 - 1e-7)));
    }
    return loss;
  }

  @override
  void backward(Vector2 dvalues, Vector1 yTrue) {
    var samples = dvalues.length;
    var labels = dvalues[0].length;

    // convert y to one-hot vector
    Vector2 eyeTemp = Vector2.eye(labels);
    Vector2 yTrueOneHot = Vector2.empty();
    for (var i = 0; i < dvalues.length; i++) {
      yTrueOneHot.add(eyeTemp[yTrue[i] as int]);
    }
    Vector2 dinputs = ((yTrueOneHot * -1) / dvalues) as Vector2;
    dinputs = (dinputs / samples) as Vector2;

    this.dinputs = dinputs;
  }
}
