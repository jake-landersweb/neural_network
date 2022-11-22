import 'dart:async';

import 'package:neural_network/network/activation.dart';
import 'package:neural_network/network/relu.dart';
import 'package:neural_network/network/root.dart';
import 'package:neural_network/network/utils.dart';

class Layer {
  late int inputSize;
  late int neuronSize;
  late List<List<double>> weights;
  // neuron values
  late List<double> bias;
  late Activation activation;

  // forward pass values
  List<List<double>>? inputs;
  List<List<double>>? outputs;

  // backward pass values
  List<List<double>>? dinputs;
  List<List<double>>? dweights;
  List<double>? dbias;

  // momentum values
  List<List<double>>? weightMomentums;
  List<double>? biasMomentums;

  // weight cache values
  List<List<double>>? weightCache;
  List<double>? biasCache;

  // regularization values
  late double weightRegL2;
  late double biasRegL2;

  Layer({
    required int inputs,
    required int neurons,
    required this.activation,
    int? seed,
    this.weightRegL2 = 0,
    this.biasRegL2 = 0,
  }) {
    inputSize = inputs;
    neuronSize = neurons;
    weights = randomList2D(inputs, neurons, seed: seed);
    bias = List.generate(neurons, (index) => 0);
  }

  Layer.fromMap(Map<String, dynamic> map) {
    weights = [];
    for (var i in map['weights']) {
      weights.add([for (var j in i) j]);
    }
    bias = [];
    for (var i in map['bias']) {
      bias.add(i is int ? i.toDouble() : i);
    }
    switch (map['activation']) {
      case "relu":
        activation = ReLU();
        break;
      case "softmax":
        activation = Softmax();
        break;
      default:
        print("Unknown activation function: ${map['activation']}");
    }
    weightRegL2 = map['weightRegL2'] is int
        ? map['weightRegL2'].toDouble()
        : map['weightRegL2'];
    biasRegL2 = map['biasRegL2'] is int
        ? map['biasRegL2'].toDouble()
        : map['biasRegL2'];
    inputSize = map['inputSize'];
    neuronSize = map['neuronSize'];
  }

  void forward(List<List<double>> inputs) {
    assert(inputs.first.length == weights.length);
    this.inputs = inputs;

    var dotprod = inputs.dot2D(weights);
    dotprod = dotprod.replaceWhere((i, j) => dotprod[i][j] + bias[j]);
    activation.forward(dotprod);
    outputs = activation.outputs;
  }

  void backward(List<List<double>> dvalues) {
    // gradient on activation
    activation.backward(dvalues);

    // gradient on params
    dweights = inputs!.T.dot2D(activation.dinputs!);
    dbias = activation.dinputs!.T.sum();

    // gradients on regularization
    if (weightRegL2 > 0) {
      dweights = dweights!.replaceWhere(
          (i, j) => dweights![i][j] + (weights[i][j] * (2 * weightRegL2)));
    }
    if (biasRegL2 > 0) {
      dbias =
          dbias!.replaceWhere((i) => dbias![i] + (bias[i] * (2 * biasRegL2)));
    }

    // gradient on values
    dinputs = activation.dinputs!.dot2D(weights.T);
  }

  Map<String, dynamic> toMap() {
    return {
      "weights": weights,
      "bias": bias,
      "activation": activation.name(),
      "weightRegL2": weightRegL2,
      "biasRegL2": biasRegL2,
      "inputSize": inputSize,
      "neuronSize": neuronSize,
    };
  }

  List<int> shape() {
    return [inputSize, neuronSize];
  }

  /// Get comprehensive stats about the whole network
  Map<String, dynamic> stats() {
    return {
      "activation": activation.name(),
      "weightRegL2": weightRegL2,
      "biasRegL2": biasRegL2,
      "inputs": inputSize,
      "neurons": neuronSize,
      "shape": shape(),
    };
  }
}
