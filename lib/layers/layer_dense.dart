import 'dart:math';

import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/main.dart';
import 'package:flutter_nn/vector/root.dart';

class LayerDense extends Layer {
  late Vector2 weights;
  late Vector1 biases;
  Vector2? inputs;
  Vector2? output;

  // back prop values
  Vector2? dweights;
  Vector2? dbiases;
  Vector2? dinputs;

  LayerDense(int inputs, int neurons, {int seed = SEED}) {
    Random rng = Random(seed);
    weights = Vector2.empty();
    // generate random small values
    for (var i = 0; i < inputs; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < neurons; j++) {
        temp.add(rng.nextDouble() * 0.01);
      }
      weights.add(temp);
    }
    biases = Vector1(neurons, fill: 0);
  }

  @override
  void forward(Vector2 inputs) {
    assert(inputs[0].length == weights.length,
        "The elements inside of inputs need to be of the same length as the weights");
    // save the inputs for backprop
    this.inputs = inputs;
    // run forward pass
    output = (dot(inputs, weights) + biases) as Vector2;
  }

  @override
  void backward(Vector2 dvalues) {
    assert(inputs != null, "inputs is null, run forward() first");
    // gradients on params
    dweights = dot(inputs!.T, dvalues) as Vector2;
    dbiases = dvalues.T.sum(keepDims: true) as Vector2;
    // gradients on values
    dinputs = dot(dvalues, weights.T) as Vector2;
  }

  @override
  String toString() {
    return "Inputs:\n$inputs\nWeights:\n$weights\nBiases:\n$biases\ndWeights:\n$dweights\ndBiases:\n$dbiases\ndInputs:\n$dinputs";
  }
}
