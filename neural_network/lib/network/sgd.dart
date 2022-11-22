import 'package:neural_network/network/layer.dart';
import 'utils.dart';

class SGD {
  late int iterations;
  late double learningRate;

  SGD({
    this.learningRate = 0.005,
  }) {
    iterations = 0;
  }

  void pre() {}

  void update(Layer layer) {
    layer.weights = layer.weights.replaceWhere((i, j) =>
        layer.weights[i][j] + (layer.dweights![i][j] * -learningRate));
    layer.bias = layer.bias
        .replaceWhere((i) => layer.bias[i] + (layer.dbias![i] * -learningRate));
  }

  void post() {
    iterations += 1;
  }
}
