import 'package:neural_network/network/activation.dart';
import 'dart:math' as math;
import 'utils.dart';

class ReLU extends Activation {
  @override
  void forward(List<List<double>> inputs) {
    outputs = inputs.replaceWhere((i, j) => math.max(0, inputs[i][j]));
  }

  @override
  void backward(List<List<double>> dvalues) {
    dinputs = dvalues.replaceWhere((i, j) => math.max(0, dvalues[i][j]));
  }
}
