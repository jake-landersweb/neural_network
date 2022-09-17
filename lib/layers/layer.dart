import 'package:flutter_nn/vector/root.dart';

abstract class Layer {
  late Vector2 weights;
  late Vector2 biases;
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

  // required functional implementations
  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);

  @override
  String toString() {
    return "Inputs:\n$inputs\nWeights:\n$weights\nBiases:\n$biases\ndWeights:\n$dweights\ndBiases:\n$dbiases\ndInputs:\n$dinputs";
  }
}
