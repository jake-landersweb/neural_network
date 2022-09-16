import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/vector/root.dart';

/// This is a very fast activation algorithm while still
/// maintaining the ability to map non-linear functions
class ActivationReLU extends Activation {
  Vector2? inputs;
  Vector2? output;
  Vector2? dinputs;

  @override
  void forward(Vector2 inputs) {
    // save inputs
    this.inputs = Vector2.fromVector(inputs);

    // calculate the output values from the inputs
    output = maximum(0, inputs) as Vector2;
  }

  @override
  void backward(Vector2 dvalues) {
    // make a copy of dvalues since we will be modifying it
    dinputs = Vector2.fromVector(dvalues);

    // zero the gradient where the values are negative
    dinputs = minimum(0, dinputs!) as Vector2;
  }
}
