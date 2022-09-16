import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/vector/root.dart';

/// class to combine the functionality of the ActivationSoftmax
/// class and the LossCategoricalCrossentropy into a single
/// class to speed up computation.
class ActivationSoftmaxLossCategoricalCrossentropy {
  final ActivationSoftMax activation = ActivationSoftMax();
  final LossCategoricalCrossentropy lossfxn = LossCategoricalCrossentropy();
  Vector2? output;
  Vector2? dinputs;

  double forward(Vector2 inputs, Vector1 yTrue) {
    activation.forward(inputs);
    output = activation.output;
    return lossfxn.calculate(activation.output!, yTrue);
  }

  void backward(Vector2 dvalues, Vector yTrue) {
    assert(dvalues.length == yTrue.length,
        "dvalues (2D) and labels (1D) need to be the same length");

    // if values are one hot encoded, turn them into
    // discrete values
    late Vector1 yTrueFlat;
    if (yTrue is Vector2) {
      yTrueFlat = yTrue.flatMax();
    } else {
      yTrueFlat = Vector1.fromVector(yTrue as Vector1);
    }

    // copy so we can safely modify
    dinputs = Vector2.fromVector(dvalues);

    Vector2 dinputs1 = Vector2.empty();
    for (var i = 0; i < dvalues.length; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < dvalues[i].length; j++) {
        if (j == yTrueFlat[i]) {
          temp.add(dvalues[i][j] - 1);
        } else {
          temp.add(dvalues[i][j]);
        }
      }
      dinputs1.add(temp);
    }
    dinputs = (dinputs1 / dvalues.length) as Vector2;
  }
}
