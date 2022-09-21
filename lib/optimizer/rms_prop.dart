import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/optimizer/root.dart';
import 'package:flutter_nn/vector/root.dart';

/// This optimizer needs a SMALL learning rate. The default
/// used in most frameworks is 0.001
class OptimizerRMSProp extends Optimizer {
  late double epsilon;
  late double rho;

  OptimizerRMSProp({
    double learningRate = 0.001,
    double decay = 0,
    this.epsilon = 1e-7,
    this.rho = 0.9,
  }) {
    this.learningRate = learningRate;
    this.decay = decay;
    currentLearningRate = learningRate;
    iterations = 0;
  }

  @override
  OptimizerRMSProp.fromMap(Map<String, dynamic> map) {
    learningRate = map['learningRate'];
    currentLearningRate = map['currentLearningRate'];
    iterations = map['iterations'];
    decay = map['decay'];
    epsilon = map['epsilon'];
    rho = map['rho'];
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

  @override
  String name() {
    return "rms";
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name(),
      "learningRate": learningRate,
      "currentLearningRate": currentLearningRate,
      "decay": decay,
      "iterations": iterations,
      "epsilon": epsilon,
      "rho": rho,
    };
  }
}
