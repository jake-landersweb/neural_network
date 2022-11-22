import 'package:neural_network/network/layer.dart';
import 'package:neural_network/network/optimizer.dart';
import 'utils.dart';

class SGD extends Optimizer {
  late int iterations;
  late double learningRate;

  SGD({
    this.learningRate = 0.005,
  }) {
    iterations = 0;
  }

  @override
  void pre() {}

  @override
  void update(Layer layer) {
    layer.weights = layer.weights.replaceWhere((i, j) =>
        layer.weights[i][j] + (layer.dweights![i][j] * -learningRate));
    layer.bias = layer.bias
        .replaceWhere((i) => layer.bias[i] + (layer.dbias![i] * -learningRate));
  }

  @override
  void post() {
    iterations += 1;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "iterations": iterations,
      "learningRate": learningRate,
    };
  }
}
