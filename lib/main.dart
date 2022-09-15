import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/utils/root.dart';

void main() {
  SpiralDataset dataset = SpiralDataset(100, 3);

  LayerDense layer1 = LayerDense(
    inputs: 2,
    neurons: 3,
    activation: ActivationReLU(),
  );
  LayerDense layer2 = LayerDense(
    inputs: 3,
    neurons: 3,
    activation: ActivationSoftMax(),
  );
  Loss lossFunction = LossCategoricalCrossentropy();

  layer1.forward(dataset.X);
  layer2.forward(layer1.output);
  var loss = lossFunction.calculate(layer2.output, dataset.y);

  print(layer2.output.sublist(0, 10).pretty());
  print("Loss: $loss");
}
