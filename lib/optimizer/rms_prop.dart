import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/optimizer/root.dart';
import 'package:flutter_nn/vector/root.dart';

/// This optimizer needs a SMALL learning rate. The default
/// used in most frameworks is 0.001
class OptimizerRMSProp extends Optimizer {
  late double learningRate;
  late double currentLearningRate;
  late double decay;
  late int iterations;
  late double epsilon;
  late double rho;

  OptimizerRMSProp({
    this.learningRate = 0.001,
    this.decay = 0,
    this.epsilon = 1e-7,
    this.rho = 0.9,
  }) {
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
    // create cache vectors
    layer.weightCache ??=
        Vector2(layer.weights.shape[0], layer.weights.shape[1]);
    layer.biasCache ??= Vector2(layer.biases.shape[0], layer.biases.shape[1]);

    // update cache with squared current gradients
    layer.weightCache = ((layer.weightCache! * rho) +
        (layer.dweights!.pow(2) * (1 - rho))) as Vector2;
    layer.biasCache = ((layer.biasCache! * rho) +
        (layer.dbiases!.pow(2) * (1 - rho))) as Vector2;

    // vanilla sgd param update + normalization with square root cache
    layer.weights = layer.weights +
        ((layer.dweights! * -currentLearningRate) /
            (layer.weightCache!.sqrt() + epsilon)) as Vector2;
    layer.biases = layer.biases +
        ((layer.dbiases! * -currentLearningRate) /
            (layer.biasCache!.sqrt() + epsilon)) as Vector2;
  }

  @override
  void post() {
    iterations += 1;
  }
}