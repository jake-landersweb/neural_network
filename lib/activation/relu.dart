import 'package:flutter_nn/activation/root.dart';

/// This is a very fast activation algorithm while still
/// maintaining the ability to map non-linear functions
class ActivationReLU extends Activation {
  @override
  List<List<double>> forward(List<List<double>> inputs) {
    // loop through all and if value is less than 0, replace with 0
    for (int i = 0; i < inputs.length; i++) {
      for (int j = 0; j < inputs[0].length; j++) {
        if (inputs[i][j] < 0) {
          inputs[i][j] = 0;
        }
      }
    }
    return inputs;
  }
}
