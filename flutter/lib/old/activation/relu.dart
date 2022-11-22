import 'package:neural_network/old/activation/root.dart';
import 'package:neural_network/old/vector/root.dart';

/// This is a very fast activation algorithm while still
/// maintaining the ability to map non-linear functions
class ActivationReLU extends Activation {
  @override
  void forward(Vector2 inputs) {
    // save inputs
    this.inputs = Vector2.fromVector(inputs);
    // print(inputs.subVector(1, 2));

    // calculate the output values from the inputs
    output = maximum(0, inputs) as Vector2;
    // print(output!.subVector(1, 2));
  }

  @override
  void backward(Vector2 dvalues) {
    // make a copy of dvalues since we will be modifying it
    dinputs = Vector2.fromVector(dvalues);

    // zero the gradient where the values are negative
    dinputs =
        dinputs!.replaceWhere((i, j) => inputs![i][j] < 0 ? 0 : dinputs![i][j]);
  }

  @override
  String name() {
    return "relu";
  }
}
