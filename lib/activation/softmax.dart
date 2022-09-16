import 'dart:math';
import 'package:flutter_nn/activation/root.dart';
// import 'package:flutter_nn/utils/root.dart';
import 'package:flutter_nn/vector/root.dart';

/// output values will add up to 1. Useful for when
/// want the network to output probabilities of what it
/// 'thinks' the output should be. This is useful for a
/// classification output layer. Often used with a categorical
/// cross-entropy loss function.
class ActivationSoftMax extends Activation {
  Vector2? inputs;
  Vector2? output;
  Vector2? dinputs;

  @override
  void forward(Vector2 inputs) {
    // remember the inputs
    this.inputs = Vector2.fromVector(inputs);
    // get exponent of all rows, divide by the sum of the row
    List<List<double>> expValues = inputs.val
        .map((row) => row.map((e) => exp(e - row.max())).toList())
        .toList();
    output = Vector2.from(expValues
        .map((row) => row.map((e) => e / row.sum()).toList())
        .toList());
  }

  @override
  void backward(Vector2 dvalues) {
    Vector2 dinputs = Vector2.empty();

    for (var i = 0; i < dvalues.length; i++) {
      Vector2 singleOutput = output![i].toVector2();
      Vector2 diagFlat = Vector2.diagonalFlat(output![i].val);

      Vector2 jacobianMatrix =
          diagFlat - (dot(singleOutput, singleOutput.T) as Vector2) as Vector2;
      Vector1 temp = dot(dvalues[i], jacobianMatrix) as Vector1;
      dinputs.add(temp);
    }
    // TODO -- find where I need to reverse the sign. It should not be here
    this.dinputs = dinputs * -1 as Vector2;
  }
}

extension _1D on List<num> {
  num sum() {
    num sum = 0;
    for (var i in this) {
      sum += i;
    }
    return sum;
  }
}
