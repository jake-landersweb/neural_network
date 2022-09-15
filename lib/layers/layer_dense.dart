import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/utils/root.dart';

class LayerDense extends Layer {
  late List<List<double>> weights;
  late List<double> biases;
  List<List<double>> output = [];
  late Activation activation;

  LayerDense({
    required int inputs,
    required int neurons,
    required this.activation,
  }) {
    weights = [];
    // generate random small values
    for (var i = 0; i < inputs; i++) {
      List<double> temp = [];
      for (var j = 0; j < neurons; j++) {
        temp.add(rng.nextDouble() * 0.01);
      }
      weights.add(temp);
    }
    biases = List.filled(neurons, 0);
  }

  @override
  void forward(List<List<double>> inputs) {
    assert(inputs[0].length == weights.length,
        "The elements inside of inputs need to be of the same length as the weights");
    output = vectorSum2D1D(dot2D2D(inputs, weights), biases);
    output = activation.forward(output);
  }

  @override
  List<double> getBiases() {
    return biases;
  }

  @override
  List<List<double>> getOutputs() {
    return output;
  }

  @override
  List<List<double>> getWeights() {
    return weights;
  }
}
