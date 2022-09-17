import 'dart:math' as math;
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/optimizer/optimizer.dart';
import 'package:flutter_nn/vector/root.dart';

class OptimizerAdam extends Optimizer {
  late double learningRate;
  late double currentLearningRate;
  late double decay;
  late int iterations;
  late double epsilon;
  late double beta1;
  late double beta2;

  OptimizerAdam({
    this.learningRate = 0.001,
    this.decay = 0,
    this.epsilon = 1e-7,
    this.beta1 = 0.9,
    this.beta2 = 0.999,
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
    // initialize momentum and cache values
    layer.weightMomentums ??=
        Vector2(layer.weights.shape[0], layer.weights.shape[1]);
    layer.weightCache ??= Vector2(layer.biases.shape[0], layer.biases.shape[1]);
    layer.biasMomentums ??=
        Vector2(layer.weights.shape[0], layer.weights.shape[1]);
    layer.biasCache ??= Vector2(layer.biases.shape[0], layer.biases.shape[1]);

    // update the momentum with the current gradient
    layer.weightMomentums = (layer.weightMomentums! * beta1) +
        (layer.dweights! * (1 - beta1)) as Vector2;
    layer.biasMomentums = (layer.biasMomentums! * beta1) +
        (layer.dbiases! * (1 - beta1)) as Vector2;

    // get correct momentum
    // iterations is 0 at first pass, and we need to start with 1 here
    Vector2 weightMomentumsCorrected = layer.weightMomentums! /
        (math.pow(1 - beta1, iterations + 1)) as Vector2;
    Vector2 biasMomentumsCorrected =
        layer.biasMomentums! / (math.pow(1 - beta1, iterations + 1)) as Vector2;

    // update the cache with the squared current gradients
    layer.weightCache = (layer.weightCache! * beta2) +
        (layer.dweights!.pow(2) * (1 - beta2)) as Vector2;
    layer.biasCache = (layer.biasCache! * beta2) +
        (layer.dbiases!.pow(2) * (1 - beta2)) as Vector2;

    // get corrected cache
    Vector2 weightCacheCorrected =
        layer.weightCache! / (math.pow(1 - beta2, iterations + 1)) as Vector2;
    Vector2 biasCacheCorrected =
        layer.biasCache! / (math.pow(1 - beta2, iterations + 1)) as Vector2;

    // vanilla sgd parameter update + normalization with square root cache
    print(layer.weightCache!.shape);
    print(weightCacheCorrected.shape);
    // print((weightMomentumsCorrected * -currentLearningRate).shape);
    print(weightCacheCorrected.sqrt().shape);
    print((weightCacheCorrected.sqrt() + epsilon).shape);
    layer.weights = layer.weights +
        ((weightMomentumsCorrected * -currentLearningRate) /
            (weightCacheCorrected.sqrt() + epsilon)) as Vector2;
    layer.biases = layer.biases +
        ((biasMomentumsCorrected * -currentLearningRate) /
            (biasCacheCorrected.sqrt() + epsilon)) as Vector2;
  }

  @override
  void post() {
    iterations += 1;
  }
}
