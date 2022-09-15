import 'package:flutter_nn/utils/root.dart';

abstract class Layer {
  void forward(List<List<double>> inputs);

  List<List<double>> getWeights();
  List<double> getBiases();
  List<List<double>> getOutputs();

  @override
  String toString() {
    return "Weights:\n${getWeights().pretty()}\nBiases:\n${getBiases()}\nOutput:\n${getOutputs()}";
  }
}
