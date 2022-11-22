import 'package:neural_network/network/activation.dart';
import 'dart:math' as math;
import 'utils.dart';

class ReLU extends Activation {
  @override
  void forward(List<List<double>> inputs) {
    this.inputs = [for (var i in inputs) List.from(i)];
    outputs = inputs.replaceWhere((i, j) => math.max(0, inputs[i][j]));
  }

  @override
  void backward(List<List<double>> dvalues) {
    dinputs = [for (var i in dvalues) List.from(i)];
    dinputs =
        dvalues.replaceWhere((i, j) => inputs![i][j] < 0 ? 0 : dinputs![i][j]);
  }

  @override
  String name() => "relu";
}
