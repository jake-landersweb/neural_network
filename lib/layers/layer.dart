import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/extra/root.dart';
import 'package:flutter_nn/vector/root.dart';

abstract class Layer {
  late Vector2 weights;
  late Vector2 biases;
  late Activation activation;
  Vector2? inputs;
  Vector2? output;

  // back prop values
  Vector2? dweights;
  Vector2? dbiases;
  Vector2? dinputs;

  // momentum values
  Vector2? weightMomentums;
  Vector2? biasMomentums;

  // weight cache values
  Vector2? weightCache;
  Vector2? biasCache;

  // regularization values
  late double weightRegL1;
  late double weightRegL2;
  late double biasRegL1;
  late double biasRegL2;

  // required functional implementations
  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);

  @override
  String toString() {
    return "Inputs:\n$inputs\nWeights:\n$weights\nBiases:\n$biases\ndWeights:\n$dweights\ndBiases:\n$dbiases\ndInputs:\n$dinputs";
  }

  Map<String, dynamic> toMap() {
    // convert weights and biases to raw types
    List<List<double>> convertedWeights = [];
    List<List<double>> convertedBiases = [];
    for (Vector1 i in weights) {
      List<double> temp = [];
      for (num j in i) {
        temp.add(j.toDouble());
      }
      convertedWeights.add(temp);
    }
    for (Vector1 i in biases) {
      List<double> temp = [];
      for (num j in i) {
        temp.add(j.toDouble());
      }
      convertedBiases.add(temp);
    }
    return {
      "weights": convertedWeights,
      "biases": convertedBiases,
      "activation": activation.name(),
      "weightRegL1": weightRegL1,
      "weightRegL2": weightRegL2,
      "biasRegL1": biasRegL1,
      "biasRegL2": biasRegL2,
    };
  }
}
