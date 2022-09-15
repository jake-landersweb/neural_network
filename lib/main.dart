import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/utils/root.dart';

void main() {
  // passed in gradient from the next layer
  List<List<double>> dvalues = [
    [1.0, 1.0, 1.0],
    [2, 2, 2],
    [3, 3, 3],
  ];

  // 3 samples
  List<List<double>> inputs = [
    [1, 2, 3, 2.5],
    [2, 5, -1, 2],
    [-1.5, 2.7, 3.3, -0.8],
  ];

  // 3 sets of weights for each neuron
  List<List<double>> weights = [
    [0.2, 0.8, -0.5, 1],
    [0.5, -0.91, 0.26, -0.5],
    [-0.26, -0.27, 0.17, 0.87],
  ];

  // biases for each group of inputs
  List<double> biases = [2, 3, 0.5];

  // forward pass
  var layerOutputs =
      vectorSum2D1D(dot2D2D(inputs, weights.transpose()), biases);
  List<List<double>> reluOutputs = [];
  // for relu activation, simulating backprop with relu
  // this is not useful at all, just to help brain dump
  List<List<double>> drelu = [];

  for (var i in layerOutputs) {
    List<double> tempRelu = [];
    List<double> tempdrelu = [];

    for (var j in i) {
      if (j < 0) {
        tempRelu.add(0);
        tempdrelu.add(0);
      } else {
        tempRelu.add(j);
        tempdrelu.add(1);
      }
    }
    reluOutputs.add(tempRelu);
    drelu.add(tempdrelu);
  }

  // inputs
  var dinputs = dot2D2D(drelu, weights);
  // derivative weights
  var dweights = dot2D2D(inputs.transpose(), drelu);

  // biases all summed
  List<double> dbiases = [];
  for (var i in drelu) {
    dbiases.add(i.sum().toDouble());
  }

  // update the params
  weights = vectorSum2D2D(weights, dweights.multiply0D(-0.001).transpose());
  biases = vectorSum1D1D(
      biases, dbiases.multiply(-0.001).map((e) => e.toDouble()).toList());

  print(weights.transpose().pretty());
  print(biases);

  // List<List<double>> dinputs = dot2D2D(dvalues, weights);

  // print(dinputs.pretty());

  // SpiralDataset dataset = SpiralDataset(500, 3);

  // LayerDense layer1 = LayerDense(
  //   inputs: 2,
  //   neurons: 10,
  //   activation: ActivationReLU(),
  // );
  // LayerDense layer2 = LayerDense(
  //   inputs: 10,
  //   neurons: 10,
  //   activation: ActivationReLU(),
  // );
  // LayerDense layer3 = LayerDense(
  //   inputs: 10,
  //   neurons: 3,
  //   activation: ActivationReLU(),
  // );
  // LayerDense outLayer = LayerDense(
  //   inputs: 3,
  //   neurons: 3,
  //   activation: ActivationSoftMax(),
  // );
  // Loss lossFunction = LossCategoricalCrossentropy();

  // layer1.forward(dataset.X);
  // layer2.forward(layer1.output);
  // layer3.forward(layer2.output);
  // outLayer.forward(layer3.output);
  // var loss = lossFunction.calculate(outLayer.output, dataset.y);

  // // calculate accuracy
  // int correct = 0;
  // for (var i = 0; i < dataset.y.length; i++) {
  //   if (outLayer.output[i].maxIndex() == dataset.y[i]) {
  //     correct += 1;
  //   }
  // }
  // double accuracy = correct / dataset.y.length;

  // print(outLayer.output.sublist(0, 10).pretty());
  // print("Loss: $loss");
  // print("Accuracy = $accuracy");
}
