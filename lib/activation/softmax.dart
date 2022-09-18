import 'dart:io';
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
  @override
  void forward(Vector2 inputs) {
    // remember the inputs
    this.inputs = Vector2.fromVector(inputs);

    Vector2 expValues = Vector2.empty();

    for (var i = 0; i < inputs.length; i++) {
      Vector1 temp = Vector1.empty();
      for (var j = 0; j < inputs[i].length; j++) {
        temp.add(exp(inputs[i][j] - inputs[i].max()));
      }
      expValues.add(temp);
    }
    output = expValues / (expValues.sum(axis: 1, keepDims: true) as Vector2).T
        as Vector2;
  }

  @override
  void backward(Vector2 dvalues) {
    Vector2 dinputs = Vector2.empty();

    for (var i = 0; i < dvalues.length; i++) {
      Vector2 singleOutput = output![i].toVector2();

      Vector2 jacobianMatrix = Vector2.diagonalFlat(output![i].val) -
          (dot(singleOutput, singleOutput.T) as Vector2) as Vector2;
      Vector1 temp = dot(jacobianMatrix, dvalues[i]) as Vector1;
      dinputs.add(temp);
    }
    // TODO -- find where I need to reverse the sign. It should not be here
    // this.dinputs = dinputs * -1 as Vector2;
    this.dinputs = dinputs;
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
