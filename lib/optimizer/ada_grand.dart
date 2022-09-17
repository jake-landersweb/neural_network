import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/optimizer/optimizer.dart';
import 'package:flutter_nn/vector/root.dart';

class OptimizerAdaGrad extends Optimizer {
  late double learningRate;
  late double currentLearningRate;
  late double decay;
  late int iterations;
  late double epsilon;

  OptimizerAdaGrad(this.learningRate, {this.decay = 0, this.epsilon = 1e-7}) {
    currentLearningRate = learningRate;
    iterations = 0;
  }

  @override
  void pre() {
    if (decay != 0) {
      currentLearningRate = learningRate * (1 / (1 + decay * iterations));
    }
  }

  @override
  void update(Layer layer) {
    // create momentum arrays if needed
    layer.weightCache ??=
        Vector2(layer.weights.shape[0], layer.weights.shape[1]);
    layer.biasCache ??= Vector2(layer.biases.shape[0], layer.biases.shape[1]);

    layer.weightCache = layer.weightCache! + layer.dweights!.pow(2) as Vector2;
    layer.biasCache = layer.biasCache! + layer.dbiases!.pow(2) as Vector2;

    layer.weights = layer.weights +
        (layer.dweights! * -currentLearningRate) /
            (layer.weightCache!.sqrt() + epsilon) as Vector2;
    layer.biases = layer.biases +
        (layer.dbiases! * -currentLearningRate) /
            (layer.biasCache!.sqrt() + epsilon) as Vector2;
  }

  @override
  void post() {
    iterations += 1;
  }
}
