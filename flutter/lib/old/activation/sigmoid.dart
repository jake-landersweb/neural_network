import 'dart:math' as math;
import 'package:neural_network/old/activation/root.dart';
import 'package:neural_network/old/vector/root.dart';
import 'package:neural_network/old/vector/vector2.dart';

// TODO -- verify this works with binary classification
class ActivationSigmoid extends Activation {
  @override
  void forward(Vector2 inputs) {
    this.inputs = inputs;
    output = inputs.replaceWhere((i, j) => 1 / (1 + math.exp(-inputs[i][j])));
  }

  @override
  void backward(Vector2 dvalues) {
    dinputs = dvalues *
        (output!.replaceWhere((i, j) => 1 - output![i][j])) *
        output as Vector2;
  }

  @override
  String name() {
    return "sigmoid";
  }
}
