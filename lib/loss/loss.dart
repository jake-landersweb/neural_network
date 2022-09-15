import 'package:flutter_nn/utils/root.dart';

abstract class Loss {
  List<double> forward(List<List<double>> predictions, List<int> labels);

  double calculate(List<List<double>> predictions, List<int> labels) {
    // get each sample loss value
    List<double> loss = forward(predictions, labels);
    // return the mean of the loss values
    return loss.mean().toDouble();
  }
}
