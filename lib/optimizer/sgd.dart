import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/optimizer/optimizer.dart';
import 'package:flutter_nn/vector/root.dart';

class OptimizerSGD extends Optimizer {
  late double decay;
  late int iterations;
  late double momentum;

  OptimizerSGD(double learningRate, {this.decay = 0, this.momentum = 0}) {
    this.learningRate = learningRate;
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
}
