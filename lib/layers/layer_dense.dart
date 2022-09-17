import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/main.dart';
import 'package:flutter_nn/vector/root.dart';

class LayerDense extends Layer {
  LayerDense(int inputs, int neurons, {int seed = SEED}) {
    weights = Vector2.random(inputs, neurons, scaleFactor: 0.01, seed: seed);
    biases = Vector2.from([Vector1(neurons, fill: 0).val]);
  }

  @override
  void forward(Vector2 inputs) {
    assert(inputs[0].length == weights.length,
        "The elements inside of inputs need to be of the same length as the weights");
    // save the inputs for backprop
    this.inputs = inputs;
    // run forward pass
    output = (dot(inputs, weights) + biases) as Vector2;
    // print("OUT: $output");
  }

  @override
  void backward(Vector2 dvalues) {
    assert(inputs != null, "inputs is null, run forward() first");
    // gradients on params
    dweights = dot(inputs!.T, dvalues) as Vector2;
    dbiases = dvalues.sum(axis: 0, keepDims: true) as Vector2;
    // gradients on values
    dinputs = dot(dvalues, weights.T) as Vector2;
  }
}
