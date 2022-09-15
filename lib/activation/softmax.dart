import 'dart:math';
import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/utils/root.dart';

/// output values will add up to 1. Useful for when
/// want the network to output probabilities of what it
/// 'thinks' the output should be. This is useful for a
/// classification output layer
class ActivationSoftMax extends Activation {
  @override
  List<List<double>> forward(List<List<double>> inputs) {
    // get exponent of all rows, divide by the sum of the row
    List<List<double>> expValues = inputs
        .map((row) => row.map((e) => exp(e - row.max())).toList())
        .toList();
    return expValues
        .map((row) => row.map((e) => e / row.sum()).toList())
        .toList();
  }
}
