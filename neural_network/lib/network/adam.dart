import 'package:neural_network/network/layer.dart';
import 'package:neural_network/network/optimizer.dart';
import 'utils.dart';
import 'dart:math' as math;

class Adam extends Optimizer {
  late double learningRate;
  late double currentLearningRate;
  late double decay;
  late int iterations;
  late double epsilon;
  late double beta1;
  late double beta2;

  Adam({
    this.learningRate = 0.001,
    this.decay = 0,
    this.epsilon = 1e-7,
    this.beta1 = 0.9,
    this.beta2 = 0.999,
  }) {
    currentLearningRate = learningRate;
    iterations = 0;
  }

  Adam.fromMap(Map<String, dynamic> map) {
    learningRate = map['learningRate'];
    currentLearningRate = map['currentLearningRate'];
    decay = map['decay'];
    iterations = map['iterations'];
    epsilon = map['epsilon'];
    beta1 = map['beta1'];
    beta2 = map['beta2'];
  }

  @override
  void pre() {
    if (decay != 0) {
      currentLearningRate = learningRate * (1 / (1 + decay * iterations));
    }
  }

  @override
  void update(Layer layer) {
    // init momentum and cache values
    layer.weightMomentums ??= List.generate(layer.weights.length,
        (idx) => List.generate(layer.weights.first.length, (idx2) => 0));
    layer.weightCache ??= List.generate(layer.weights.length,
        (idx) => List.generate(layer.weights.first.length, (idx2) => 0));
    layer.biasMomentums ??= List.generate(layer.bias.length, (index) => 0);
    layer.biasCache ??= List.generate(layer.bias.length, (index) => 0);

    // update momentum with current gradients
    layer.weightMomentums = layer.weightMomentums!.replaceWhere((i, j) =>
        (layer.weightMomentums![i][j] * beta1) +
        (layer.dweights![i][j] * (1 - beta1)));
    layer.biasMomentums!.replaceWhere((i) =>
        (layer.biasMomentums![i] * beta1) + (layer.dbias![i] * (1 - beta1)));

    // get correct momentum
    // iterations is 0 at first pass, and we need to start with 1 here
    List<List<double>> weightMomentumsCorrected = layer.weightMomentums!
        .replaceWhere((i, j) =>
            layer.weightMomentums![i][j] /
            (1 - math.pow(beta1, iterations + 1)));
    List<double> biasMomentumsCorrected = layer.biasMomentums!.replaceWhere(
        (i) => layer.biasMomentums![i] / (1 - math.pow(beta1, iterations + 1)));

    // update the cache with the squared current gradients
    layer.weightCache = layer.weightCache!.replaceWhere((i, j) =>
        (layer.weightCache![i][j] * beta2) +
        (math.pow(layer.dweights![i][j], 2) * (1 - beta2)));
    layer.biasCache = layer.biasCache!.replaceWhere((i) =>
        (layer.biasCache![i] * beta2) +
        (math.pow(layer.dbias![i], 2) * (1 - beta2)));

    // get corrected cache
    List<List<double>> weightCacheCorrected = layer.weightCache!.replaceWhere(
        (i, j) =>
            layer.weightCache![i][j] / (1 - math.pow(beta2, iterations + 1)));
    List<double> biasCacheCorrected = layer.biasCache!.replaceWhere(
        (i) => layer.biasCache![i] / (1 - math.pow(beta2, iterations + 1)));

    // vanilla sgd parameter update + normalization with square root cache
    layer.weights = layer.weights.replaceWhere((i, j) =>
        layer.weights[i][j] +
        ((weightMomentumsCorrected[i][j] * -currentLearningRate) /
            (math.sqrt(weightCacheCorrected[i][j]) + epsilon)));
    layer.bias = layer.bias.replaceWhere((i) =>
        layer.bias[i] +
        ((biasMomentumsCorrected[i] * -currentLearningRate) /
            (math.sqrt(biasCacheCorrected[i]) + epsilon)));
  }

  @override
  void post() {
    iterations += 1;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "learningRate": learningRate,
      "currentLearningRate": currentLearningRate,
      "decay": decay,
      "iterations": iterations,
      "epsilon": epsilon,
      "beta1": beta1,
      "beta2": beta2,
    };
  }
}
