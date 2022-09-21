import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/optimizer/optimizer.dart';
import 'package:flutter_nn/vector/root.dart';

class OptimizerAdaGrad extends Optimizer {
  late double epsilon;

  @override
  OptimizerAdaGrad(
    double learningRate, {
    double decay = 0,
    this.epsilon = 1e-7,
  }) {
    this.learningRate = learningRate;
    currentLearningRate = learningRate;
    this.decay = decay;
    iterations = 0;
  }

  @override
  OptimizerAdaGrad.fromMap(Map<String, dynamic> map) {
    learningRate = map['learningRate'];
    currentLearningRate = map['currentLearningRate'];
    decay = map['decay'];
    iterations = map['iterations'];
    epsilon = map['epsilon'];
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

  @override
  String name() {
    return "ada";
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
    };
  }
}
