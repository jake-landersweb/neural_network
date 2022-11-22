import 'package:neural_network/network/activation.dart';
import 'dart:math' as math;
import 'utils.dart';

class Softmax extends Activation {
  @override
  void forward(List<List<double>> inputs) {
    List<List<double>> expValues =
        inputs.replaceWhere((i, j) => math.exp(inputs[i][j] - inputs[i].max()));

    List<List<double>> out = [];

    for (int i = 0; i < expValues.length; i++) {
      List<double> temp = [];
      for (var j in expValues[i]) {
        temp.add(j / expValues[i].sum());
      }
      out.add(temp);
    }
    outputs = out;
  }

  @override
  void backward(List<List<double>> dvalues) {
    List<List<double>> dinputs = [];

    for (var i = 0; i < dvalues.length; i++) {
      List<List<double>> singleOutput = outputs![i].to2D();
      List<List<double>> jm1 = diagonalFlat(outputs![i]);
      List<List<double>> jm2 = singleOutput.dot2D(singleOutput.T);
      List<List<double>> jacobianMatrix =
          jm1.replaceWhere((i, j) => jm1[i][j] - jm2[i][j]);
      List<double> temp = jacobianMatrix.dot1D(dvalues[i]);
      dinputs.add(temp);
    }
    this.dinputs = dinputs;
  }

  @override
  String name() => "softmax";
}
