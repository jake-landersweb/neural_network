import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/utils/root.dart';

void main() {
  SpiralDataset dataset = SpiralDataset(100, 3);

  LayerDense layer1 = LayerDense(
    inputs: 2,
    neurons: 10,
    activation: ActivationReLU(),
  );
  LayerDense layer2 = LayerDense(
    inputs: 10,
    neurons: 10,
    activation: ActivationReLU(),
  );
  LayerDense layer3 = LayerDense(
    inputs: 10,
    neurons: 2,
    activation: ActivationReLU(),
  );

  layer1.forward(dataset.X);
  layer2.forward(layer1.output);
  layer3.forward(layer2.output);

  print(layer3.output.sublist(0, 10).pretty());
}
