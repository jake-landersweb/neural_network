import 'package:flutter_neural_network/old/layers/root.dart';
import 'package:flutter_neural_network/old/optimizer/optimizer.dart';
import 'package:flutter_neural_network/old/vector/root.dart';

class OptimizerSGD extends Optimizer {
  late double momentum;

  OptimizerSGD(
    double learningRate, {
    double decay = 0,
    this.momentum = 0,
  }) {
    this.learningRate = learningRate;
    this.decay = decay;
    currentLearningRate = learningRate;
    iterations = 0;
  }

  @override
  OptimizerSGD.fromMap(Map<String, dynamic> map) {
    learningRate = map['learningRate'];
    currentLearningRate = map['currentLearningRate'];
    iterations = map['iterations'];
    decay = map['decay'];
    momentum = map['momentum'];
  }

  @override
  void pre() {
    if (decay != 0) {
      currentLearningRate = learningRate * (1 / (1 + decay * iterations));
    }
  }

  @override
  void update(Layer layer) {
    late Vector2 weightUpdates;
    late Vector2 biasUpdates;
    if (momentum == 0) {
      // use vanilla sgd
      weightUpdates = (layer.dweights! * -currentLearningRate) as Vector2;
      biasUpdates = layer.dbiases! * -currentLearningRate as Vector2;
    } else {
      // create momentum arrays if needed
      layer.weightMomentums ??=
          Vector2(layer.weights.shape[0], layer.weights.shape[1]);
      layer.biasMomentums ??=
          Vector2(layer.biases.shape[0], layer.biases.shape[1]);

      weightUpdates = (layer.weightMomentums! * momentum) -
          (layer.dweights! * currentLearningRate) as Vector2;
      layer.weightMomentums = weightUpdates;

      biasUpdates = (layer.biasMomentums! * momentum) -
          (layer.dbiases! * currentLearningRate) as Vector2;
      layer.biasMomentums = biasUpdates;
    }
    layer.weights = layer.weights + weightUpdates as Vector2;
    layer.biases = layer.biases + biasUpdates as Vector2;
  }

  @override
  void post() {
    iterations += 1;
  }

  @override
  String name() {
    return "sgd";
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name(),
      "learningRate": learningRate,
      "currentLearningRate": currentLearningRate,
      "decay": decay,
      "iterations": iterations,
      "momentum": momentum,
    };
  }
}
