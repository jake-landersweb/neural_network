import 'dart:math' as math;
import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/vector/root.dart';
import 'package:flutter_nn/vector/vector2.dart';

class ActivationSigmoid extends Activation {
  @override
  void forward(Vector2 inputs) {
    this.inputs = inputs;

    Vector2 out = Vector2.empty();
    // run custom sigmoid activation function
    for (Vector1 i in inputs) {
      Vector1 temp = Vector1.empty();
      for (num j in i) {
        temp.add(1 / (1 + math.exp(-j)));
      }
      out.add(temp);
    }
    output = out;
  }

  @override
  void backward(Vector2 dvalues) {
    dinputs = dvalues * ((output! - 1) * -1) * output as Vector2;
  }
}
